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

        app.MapGet("/.well-known/assetlinks.json", () =>
                Serve(webRoot, "deep-links/assetlinks.json", "application/json"))
            .AllowAnonymous();

        app.MapGet("/.well-known/apple-app-site-association", () =>
                Serve(webRoot, "deep-links/apple-app-site-association.json", "application/json"))
            .AllowAnonymous();

        // Serve the fallback page at the original /car/<id> URL (no redirect),
        // so the address bar keeps the car id for the JavaScript in the page.
        app.MapGet("/car/{carId}", (string carId) =>
                Serve(webRoot, "car/index.html", "text/html; charset=utf-8"))
            .AllowAnonymous();

        return app;
    }

    private static IResult Serve(string webRoot, string relativePath, string contentType)
    {
        var path = Path.Combine(
            webRoot,
            relativePath.Replace('/', Path.DirectorySeparatorChar));

        return File.Exists(path)
            ? Results.File(path, contentType)
            : Results.NotFound();
    }
}
