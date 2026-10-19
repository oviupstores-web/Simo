import 'app_icons.dart';

/// Validated illustrations; functional SVGs and existing image assets stay separate.
abstract final class PremiumIcons {
  static const directory = 'assets/images/premium_icons';
  static const assets = <String, String>{
    AppIcons.budgetWallet: '$directory/budget_wallet.png',
    AppIcons.budgetPiggy: '$directory/budget_piggy.png',
    AppIcons.gridCutlery: '$directory/grid_cutlery.png',
    AppIcons.goalWeightLoss: '$directory/goal_weight_loss.png',
    AppIcons.cutlery: '$directory/cutlery.png',
    AppIcons.wallet: '$directory/wallet.png',
    AppIcons.bulb: '$directory/bulb.png',
    AppIcons.target: '$directory/target.png',
    AppIcons.trendDown: '$directory/trend_down.png',
    AppIcons.trend: '$directory/trend_up.png',
    AppIcons.dumbbell: '$directory/dumbbell.png',
    AppIcons.bolt: '$directory/bolt.png',
    AppIcons.lotus: '$directory/lotus.png',
    AppIcons.sun: '$directory/sun.png',
    AppIcons.male: '$directory/male.png',
    AppIcons.female: '$directory/female.png',
    AppIcons.leaf: '$directory/leaf.png',
    AppIcons.scale: '$directory/scale.png',
    AppIcons.clock: '$directory/clock.png',
    AppIcons.moon: '$directory/moon.png',
    AppIcons.level: '$directory/level.png',
    AppIcons.people: '$directory/people.png',
    AppIcons.flame: '$directory/flame.png',
    AppIcons.wheat: '$directory/wheat.png',
    AppIcons.drop: '$directory/drop.png',
    AppIcons.pantryReserve: '$directory/pantry_reserve.png',
    AppIcons.basket: '$directory/fruit_basket.png',
    AppIcons.cupboard: '$directory/cupboard.png',
    AppIcons.snowflake: '$directory/snowflake.png',
    AppIcons.walk: '$directory/walk.png',
    AppIcons.heartPulse: '$directory/heart_pulse.png',
    AppIcons.calendar: '$directory/calendar.png',
    AppIcons.balance: '$directory/balance.png',
    AppIcons.sparkles: '$directory/sparkles.png',
    AppIcons.block: '$directory/block.png',
    AppIcons.egg: '$directory/egg.png',
    AppIcons.skillet: '$directory/skillet.png',
    AppIcons.chefHat: '$directory/chef_hat.png',
    AppIcons.briefcase: '$directory/briefcase.png',
    AppIcons.oven: '$directory/oven.png',
    AppIcons.list: '$directory/list.png',
    AppIcons.user: '$directory/user.png',
    AppIcons.fish: '$directory/fish.png',
    AppIcons.nut: '$directory/nut.png',
    AppIcons.shrimp: '$directory/shrimp.png',
    AppIcons.sprout: '$directory/sprout.png',
    AppIcons.flag: '$directory/flag.png',
    AppIcons.child: '$directory/child.png',
    AppIcons.shield: '$directory/shield.png',
    AppIcons.baby: '$directory/baby.png',
  };

  /// Older drawings of the same objects, including the reserve help icon
  /// explicitly confirmed by the user. Existing Image widgets keep priority.
  static const secondaryAssets = <String, String>{
    AppIcons.fridge: '$directory/pantry_reserve.png',
    AppIcons.pantryFridge: '$directory/pantry_reserve.png',
    AppIcons.pantryFruitBasket: '$directory/fruit_basket.png',
    AppIcons.pantryCupboard: '$directory/cupboard.png',
    AppIcons.pantryFreezer: '$directory/snowflake.png',
    AppIcons.week: '$directory/cutlery.png',
    AppIcons.piggy: '$directory/budget_piggy.png',
    AppIcons.pantryQuickCheck: '$directory/list.png',
  };

  static String? assetFor(String svg) => assets[svg] ?? secondaryAssets[svg];

  static const pantryReserve = '$directory/pantry_reserve.png';
}
