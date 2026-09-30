import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'signup_screen.dart';

/// c02_auth_login — maître : design/masters/master_login.html (réf. 02_login.png).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              const Positioned(
                right: AppSpace.x2,
                top: 0,
                child: BasilDecor(leafWidth: 46, mirror: true, peppers: false),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.x5, AppSpace.gutter, AppSpace.x8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(alignment: Alignment.centerLeft, child: MenooBrand()),
                    const SizedBox(height: AppSpace.x8),
                    Text(
                      l.loginTitle,
                      style: AppText.of(AppFont.s30, weight: AppFont.extrabold, lineHeight: 36, tightTracking: true),
                    ),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      l.loginSubtitle,
                      style: AppText.of(AppFont.s15_5, color: AppColors.ink2, lineHeight: 23),
                    ),
                    const SizedBox(height: AppSpace.x7),
                    SocialButton(label: l.loginWithGoogle, logoSvg: BrandLogos.google),
                    const SizedBox(height: AppSpace.x3),
                    SocialButton(label: l.loginWithApple, logoSvg: BrandLogos.apple, logoSize: 19),
                    const SizedBox(height: AppSpace.x5),
                    Row(
                      children: [
                        const Expanded(child: Divider(height: 1, thickness: 1, color: AppColors.line)),
                        const SizedBox(width: AppSpace.x3),
                        Text(l.commonOr, style: AppText.of(AppFont.s13, color: AppColors.ink2)),
                        const SizedBox(width: AppSpace.x3),
                        const Expanded(child: Divider(height: 1, thickness: 1, color: AppColors.line)),
                      ],
                    ),
                    const SizedBox(height: AppSpace.x5),
                    IconTextField(icon: AppIcons.mail, hint: l.commonEmail, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: AppSpace.x3),
                    IconTextField(
                      icon: AppIcons.lock,
                      hint: l.commonPassword,
                      obscure: true,
                      trailingIcon: AppIcons.eye,
                    ),
                    const SizedBox(height: AppSpace.x3),
                    Align(alignment: Alignment.centerRight, child: TextLink(l.loginForgotPassword)),
                    const SizedBox(height: AppSpace.x5),
                    PrimaryButton(
                      label: l.loginSubmit,
                      showArrow: false,
                      onPressed: () => showMenooMessage(context, l.loginSoon),
                    ),
                    const SizedBox(height: AppSpace.x4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l.loginNoAccount, style: AppText.of(AppFont.s14, color: AppColors.ink2)),
                        TextLink(
                          l.loginCreateAccount,
                          weight: AppFont.bold,
                          onTap: () => push(context, const SignupScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.x8),
                    SizedBox(
                      height: AppSizes.loginDecorH,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Positioned(left: AppSpace.x2, bottom: 0, child: BasilDecor(leafWidth: 64)),
                          Positioned(
                            right: AppSpace.x2,
                            top: AppSpace.x2,
                            child: Transform.rotate(
                              angle: AppSizes.handTilt,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    l.loginHandwritten,
                                    textAlign: TextAlign.right,
                                    style: AppText.hand(AppFont.s22, color: AppColors.ink, lineHeight: 22),
                                  ),
                                  const SizedBox(height: AppSpace.x1),
                                  Container(
                                    height: AppSizes.handUnderlineH,
                                    width: AppSizes.handUnderlineW,
                                    decoration: const BoxDecoration(
                                      color: AppColors.orange,
                                      borderRadius: AppRadius.pillR,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppIcon(AppIcons.shield, size: 15, color: AppColors.ink2),
                        const SizedBox(width: AppSpace.x1_5),
                        Text(l.commonDataSecure, style: AppText.meta),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
