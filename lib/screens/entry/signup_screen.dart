import 'package:flutter/material.dart';

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

  void _soon() => showMenooMessage(context, 'La création du compte et la génération du menu arrivent au jalon 6.');

  @override
  Widget build(BuildContext context) {
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
                      'Créez votre compte',
                      style: AppText.of(AppFont.s30, weight: AppFont.extrabold, lineHeight: 36, tightTracking: true),
                    ),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      'Dernière étape avant votre premier menu : vos choix seront enregistrés dans votre compte.',
                      style: AppText.of(AppFont.s15_5, color: AppColors.ink2, lineHeight: 23),
                    ),
                    const SizedBox(height: AppSpace.x6),
                    const IconTextField(icon: AppIcons.user, hint: 'Prénom'),
                    const SizedBox(height: AppSpace.x3),
                    const IconTextField(icon: AppIcons.mail, hint: 'Email', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: AppSpace.x3),
                    const IconTextField(
                      icon: AppIcons.lock,
                      hint: 'Mot de passe (8 caractères ou plus)',
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
                              'J\'accepte les conditions d\'utilisation et la politique de confidentialité.',
                              style: AppText.of(AppFont.s13, color: AppColors.ink2, lineHeight: 19),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.x5),
                    PrimaryButton(label: 'Créer mon compte et générer', onPressed: _accepted ? _soon : null),
                    const SizedBox(height: AppSpace.x5),
                    Row(
                      children: [
                        const Expanded(child: Divider(height: 1, thickness: 1, color: AppColors.line)),
                        const SizedBox(width: AppSpace.x3),
                        Text('ou continuer avec', style: AppText.of(AppFont.s13, color: AppColors.ink2)),
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
                        Text('Déjà inscrit ? ', style: AppText.of(AppFont.s14, color: AppColors.ink2)),
                        TextLink(
                          'Se connecter',
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
                        Text('Vos données sont sécurisées', style: AppText.meta),
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
