import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/routes.dart';
import '../providers/user_provider.dart';
import '../widgets/animated_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  Future<void> _sendCode() async {
    FocusScope.of(context).unfocus();
    final user = context.read<UserProvider>();
    final ok = await user.sendOtp(_phoneController.text);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رقم الموبايل مش صحيح، اكتبه بالصيغة: 01012345678'),
        ),
      );
    }
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    final user = context.read<UserProvider>();
    final ok = await user.verifyOtp(_phoneController.text, _otpController.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text('أهلاً بيك في بلية 🍛'),
        ),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text(
            'الكود غلط! جرب الكود التجريبي: ${AppInfo.demoOtp}',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpStep = context.watch<UserProvider>().otpSent;
    final busy = context.select<UserProvider, bool>((u) => u.busy);

    return Scaffold(
      appBar: AppBar(title: Text(otpStep ? 'كود التحقق' : 'تسجيل الدخول')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Hero(
              tag: 'login_logo',
              child: CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.primary.withValues(alpha: .15),
                child: const Text('🍛', style: TextStyle(fontSize: 56)),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              otpStep
                  ? 'اكتب الكود اللي وصلك'
                  : 'بالدخول هتعرف طلباتك وتحفظ عناوينك',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
            const SizedBox(height: 26),
            if (!otpStep)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 11,
                decoration: const InputDecoration(
                  hintText: '01xxxxxxxxx',
                  counterText: '',
                  prefixIcon: Icon(
                    Icons.phone_android_rounded,
                    color: AppColors.primary,
                  ),
                  labelText: 'رقم الموبايل',
                ),
              )
            else ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 26,
                  letterSpacing: 12,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.primary,
                  ),
                  labelText: 'الكود المكوّن من 6 أرقام',
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ActionChip(
                  avatar: const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  label: const Text(
                    'نسيت تكتب الكود؟ التجريبي هو ${AppInfo.demoOtp}',
                    style: TextStyle(fontSize: 12.5),
                  ),
                  onPressed: () => _otpController.text = AppInfo.demoOtp,
                ),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () => context.read<UserProvider>().resetOtpFlow(),
                child: const Text('غيير الرقم / إعادة الإرسال'),
              ),
            ],
            const SizedBox(height: 22),
            AnimatedButton(
              label: otpStep ? 'دخول' : 'إرسال كود التحقق',
              icon: otpStep ? Icons.login_rounded : Icons.sms_outlined,
              onPressed: busy ? null : () => otpStep ? _verify() : _sendCode(),
            ),
          ],
        ),
      ),
    );
  }
}
