// Alternative to the IIS URL Rewrite rules, for the ASP.NET Core app that
// serves https://delta-asg.com:443.
//
// Why this exists: ASP.NET Core's default WebRootFileProvider excludes
// dot-prefixed paths (.well-known), and an extensionless file is not served
// with "application/json" even when static files are enabled. Minimal API
// endpoints bypass both limitations and guarantee: 200, correct Content-Type,
// no redirect, no authentication.
//
// Placement in Program.cs (before the Blazor/SPA fallback):
//
//   var app = builder.Build();
//   ...
//   app.UseStaticFiles();          // must already be present for /car/index.html
//   app.UseAuthentication();
//   app.UseAuthorization();
//   app.MapDeepLinkEndpoints();    // <-- add this line
//   app.MapRazorComponents<App>().AddInteractiveServerRenderMode();
//   app.Run();
//
// Files on disk (under the app's wwwroot):
//   wwwroot/deep-links/assetlinks.json
//   wwwroot/deep-links/apple-app-site-association.json
//   wwwroot/car/index.html
//
// Adjust the namespace to match the server project.

using System.IO;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;

namespace DeltaAsg;

public static class DeepLinkEndpoints
{
    public static WebApplication MapDeepLinkEndpoints(this WebApplication app)
    {
        var webRoot = app.Environment.WebRootPath
            ?? Path.Combine(app.Environment.ContentRootPath, "wwwroot");

        app.MapGet("/.well-known/assetlinks.json", (HttpContext context) =>
                Serve(context, webRoot, "deep-links/assetlinks.json", "application/json"))
            .AllowAnonymous();

        app.MapGet("/.well-known/apple-app-site-association", (HttpContext context) =>
                Serve(context, webRoot, "deep-links/apple-app-site-association.json", "application/json"))
            .AllowAnonymous();

        // Serve the fallback page at the original /car, /car/ and /car/<id>
        // URLs (no redirect), so the address bar keeps the car id for the
        // JavaScript in the page. A catch-all is used so /car, /car/ and any
        // trailing segments all render the same page.
        app.MapGet("/car", (HttpContext context) =>
                Serve(context, webRoot, "car/index.html", "text/html; charset=utf-8"))
            .AllowAnonymous();

        app.MapGet("/car/{**rest}", (HttpContext context) =>
                Serve(context, webRoot, "car/index.html", "text/html; charset=utf-8"))
            .AllowAnonymous();

        return app;
    }

    private static IResult Serve(
        HttpContext context,
        string webRoot,
        string relativePath,
        string contentType)
    {
        var path = Path.Combine(
            webRoot,
            relativePath.Replace('/', Path.DirectorySeparatorChar));

        if (!File.Exists(path))
        {
            return Results.NotFound();
        }

        // Universal Links / App Links files change when signing keys change.
        // Keep the cache short so a corrected file takes effect quickly.
        if (relativePath.StartsWith("deep-links/", StringComparison.Ordinal))
        {
            context.Response.Headers.CacheControl = "public, max-age=300";
        }
        else
        {
            context.Response.Headers.CacheControl = "no-cache";
        }

        return Results.File(path, contentType);
    }
}
