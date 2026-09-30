import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../navigation.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'login_screen.dart';

/// c03_auth_signup — équivalent inscription du maître de connexion (DESIGN_V2).
/// La création réelle du compte (Supabase Auth) et la génération arrivent au jalon 6.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _accepted = false;

  void _soon() => showMenooMessage(context, L.of(context).signupSoon);

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
                padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.x4, AppSpace.gutter, AppSpace.x8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(alignment: Alignment.centerLeft, child: HeaderBackButton()),
                    const SizedBox(height: AppSpace.x2),
                    const Align(alignment: Alignment.centerLeft, child: MenooBrand()),
                    const SizedBox(height: AppSpace.x6),
                    Text(
                      l.signupTitle,
                      style: AppText.of(AppFont.s30, weight: AppFont.extrabold, lineHeight: 36, tightTracking: true),
                    ),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      l.signupSubtitle,
                      style: AppText.of(AppFont.s15_5, color: AppColors.ink2, lineHeight: 23),
                    ),
                    const SizedBox(height: AppSpace.x6),
                    IconTextField(icon: AppIcons.user, hint: l.commonFirstName),
                    const SizedBox(height: AppSpace.x3),
                    IconTextField(icon: AppIcons.mail, hint: l.commonEmail, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: AppSpace.x3),
                    IconTextField(
                      icon: AppIcons.lock,
                      hint: l.signupPasswordHint,
                      obscure: true,
                      trailingIcon: AppIcons.eye,
                    ),
                    const SizedBox(height: AppSpace.x4),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _accepted = !_accepted),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SquareCheck(checked: _accepted, onChanged: (v) => setState(() => _accepted = v)),
                          const SizedBox(width: AppSpace.x2_5),
                          Expanded(
                            child: Text(
                              l.signupAcceptTerms,
                              style: AppText.of(AppFont.s13, color: AppColors.ink2, lineHeight: 19),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.x5),
                    PrimaryButton(label: l.signupSubmit, onPressed: _accepted ? _soon : null),
                    const SizedBox(height: AppSpace.x5),
                    Row(
                      children: [
                        const Expanded(child: Divider(height: 1, thickness: 1, color: AppColors.line)),
                        const SizedBox(width: AppSpace.x3),
                        Text(l.signupOrContinueWith, style: AppText.of(AppFont.s13, color: AppColors.ink2)),
                        const SizedBox(width: AppSpace.x3),
                        const Expanded(child: Divider(height: 1, thickness: 1, color: AppColors.line)),
                      ],
                    ),
                    const SizedBox(height: AppSpace.x5),
                    Row(
                      children: [
                        Expanded(
                          child: SocialButton(label: 'Google', logoSvg: BrandLogos.google, onPressed: _soon),
                        ),
                        const SizedBox(width: AppSpace.x3),
                        Expanded(
                          child: SocialButton(
                            label: 'Apple',
                            logoSvg: BrandLogos.apple,
                            logoSize: 19,
                            onPressed: _soon,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.x5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l.signupAlreadyMember, style: AppText.of(AppFont.s14, color: AppColors.ink2)),
                        TextLink(
                          l.loginSubmit,
                          weight: AppFont.bold,
                          onTap: () =>
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.x5),
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
