import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { setLaunchParams } from '../runtime/LaunchParams';

const DOMAIN = 0x0000;
const DEFAULT_PAGE = 'pages/Index';
const PUBLIC_SURFACES: Record<string, boolean> = {
  'onboarding_preferences': true,
  'privacy_setup': true,
  'first_account_setup': true,
  'home': true,
  'accounts': true,
  'account_form': true,
  'account_delete_confirmation': true,
  'transactions': true,
  'transaction_form': true,
  'transaction_delete_confirmation': true,
  'transaction_filter': true,
  'templates': true,
  'template_detail': true,
  'planned_detail': true,
  'more_sheet': true,
  'fints_gate': true,
  'settings': true,
  'settings_data': true,
  'settings_user_interface': true,
  'settings_theme': true,
  'settings_language': true,
  'settings_start_screen': true,
  'settings_account_list': true,
  'settings_auto_fill': true,
  'settings_transaction_list': true,
  'master_data': true,
  'budgets': true,
  'budget_detail': true,
  'reports': true
};
const PUBLIC_FIXTURES: Record<string, boolean> = {
  'onboarding_preferences': true,
  'privacy_setup': true,
  'first_account_setup': true,
  'empty_home': true,
  'more_sheet': true,
  'fints_gate': true,
  'two_accounts_with_transactions': true,
  'settings_defaults': true,
  'transaction_crud': true,
  'transaction_mapping': true,
  'master_data_crud': true,
  'budgeting': true,
  'templates_planner': true,
  'reports_seed': true,
  'reports_variant': true
};

export default class EntryAbility extends UIAbility {
  private launchPage: string = DEFAULT_PAGE;
  private windowStage: window.WindowStage | undefined = undefined;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    this.launchPage = this.resolveLaunchPage(want);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    const requestedPage = this.resolveLaunchPage(want);
    this.launchPage = requestedPage;
    hilog.info(DOMAIN, 'testTag', 'Ability onNewWant resolved page: %{public}s', requestedPage);
    this.loadPage(requestedPage);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    this.windowStage = windowStage;
    this.loadPage(this.launchPage);
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    this.windowStage = undefined;
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  private loadPage(page: string): void {
    if (!this.windowStage) {
      hilog.info(DOMAIN, 'testTag', 'WindowStage is not ready; deferred page load: %{public}s', page);
      return;
    }

    this.windowStage.loadContent(page, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load page %{public}s. Cause: %{public}s', page, JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading page: %{public}s', page);
    });
  }

  private resolveLaunchPage(want: Want): string {
    const requestedSurface = want.parameters?.['benchmark_surface'] as string;
    const requestedFixture = want.parameters?.['benchmark_fixture'] as string;
    const surface = requestedSurface && PUBLIC_SURFACES[requestedSurface] ? requestedSurface : '';
    const fixture = requestedFixture && PUBLIC_FIXTURES[requestedFixture] ? requestedFixture : '';
    setLaunchParams(surface, fixture, DEFAULT_PAGE);
    return DEFAULT_PAGE;
  }
}
