import 'package:car/features/admin/data/repo/admin_repo.dart';
import 'package:car/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:car/features/agent/data/repo/agent_repo.dart';
import 'package:car/features/agent/presentation/cubit/agent_cubit.dart';
import 'package:car/features/auth/data/repository/auth_repo.dart';
import 'package:car/features/auth/presentation/view/cubit/auth_cubit.dart';
import 'package:car/features/cart/presentation/view/cubit/cart_cubit.dart';
import 'package:car/features/favorites/presentation/view/cubit/favorites_cubit.dart';
import 'package:car/features/home/data/repository/home_repo.dart';
import 'package:car/features/home/presentation/cubit/home_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../network/api_consumer.dart';
import '../network/app_interceptors.dart';
import '../network/cert_setup.dart';
import '../network/dio_consumer.dart';

part 'services_locator_imports.dart';
