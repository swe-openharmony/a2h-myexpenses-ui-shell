import {
  SAMPLE_ACCOUNT_NAME,
  SAMPLE_BACKUP_PATH,
  SAMPLE_BALANCE,
  SAMPLE_FINTS_TRIAL_END,
  SAMPLE_PRICE_12M,
  SAMPLE_PRICE_24M,
  SAMPLE_PRICE_6M,
  SAMPLE_TRANSACTION_AMOUNT,
  SAMPLE_TRANSACTION_CATEGORY,
  SAMPLE_TRANSACTION_DATE,
  SAMPLE_TRANSACTION_PAYEE,
  SAMPLE_TRANSACTION_PROJECT
} from '../mock/Phase2Seed';
import { getLaunchParams, LaunchContext } from '../runtime/LaunchParams';
import {
  AccountRecord,
  BudgetRecord,
  CategoryRecord,
  getMyExpensesStore,
  MyExpensesStore,
  PlannedRecord,
  TemplateRecord,
  TransactionRecord
} from '../model/MyExpensesStore';

export enum Phase2State {
  PreferenceSetup = 'preference_setup',
  PrivacyBackup = 'privacy_backup',
  FirstAccountSetup = 'first_account_setup',
  EmptyHome = 'empty_home',
  MoreBottomSheet = 'more_bottom_sheet',
  Settings = 'settings_main',
  FintsPremiumGate = 'fints_premium_gate',
  PremiumPurchaseOptions = 'premium_purchase_options'
}

const BG: string = '#F9F7FF';
const TEXT: string = '#20212B';
const SECONDARY: string = '#5F6070';
const LINE: string = '#DAD8E2';
const TEAL: string = '#009B8E';
const TEAL_DARK: string = '#007F73';
const BUTTON: string = '#52679E';
const PANEL: string = '#FFFBFE';
const PEACH: string = '#FFE1CC';
const OUTLINE: string = '#7A726F';

@Component
export struct MyExpensesShell {
  private store: MyExpensesStore = getMyExpensesStore();
  private launchSequence: number = -1;
  @State currentRoute: string = 'onboarding_preferences';
  @State revision: number = 0;
  @State activeAccountName: string = 'Budget Book';
  @State activeBalance: string = '0.00';
  @State signalLabels: string[] = [];
  @State accounts: AccountRecord[] = [];
  @State transactions: TransactionRecord[] = [];
  @State categories: string[] = [];
  @State categoryRecords: CategoryRecord[] = [];
  @State tags: string[] = [];
  @State payees: string[] = [];
  @State paymentMethods: string[] = [];
  @State budgets: BudgetRecord[] = [];
  @State templates: TemplateRecord[] = [];
  @State planned: PlannedRecord[] = [];
  @State reportRows: string[] = [];
  @State currencies: string[] = [];
  @State themeOptions: string[] = [];
  @State advancedAccountFields: string[] = [];
  @State restoreUnavailableSummary: string = '';
  @State reportPeriods: string[] = [];
  @State activeReportPeriod: string = '';
  @State selectedBusinessLabel: string = '';
  @State signal0: string = '';
  @State signal1: string = '';
  @State signal2: string = '';
  @State preferenceSummaries: string[] = [];
  @State autoBackupEnabled: boolean = false;
  @State fontSizePreference: string = 'Normal';

  aboutToAppear() {
    this.consumeLaunchParams();
  }

  private consumeLaunchParams(): void {
    const params: LaunchContext = getLaunchParams();
    if (params.sequence === this.launchSequence) {
      return;
    }
    this.launchSequence = params.sequence;
    if (params.fixture.length > 0) {
      this.store.resetToProfile(params.fixture, params.surface);
    } else if (params.surface.length > 0) {
      this.store.openSurface(params.surface);
    }
    this.syncFromStore();
  }

  private syncFromStore(): void {
    this.currentRoute = this.store.route;
    this.activeAccountName = this.store.activeAccountName;
    this.activeBalance = this.store.getActiveBalance();
    this.signalLabels = this.store.signalLabels.slice();
    this.accounts = this.store.accounts.slice();
    this.transactions = this.store.getActiveTransactions();
    this.categories = this.store.categories.slice();
    this.categoryRecords = this.store.categoryRecords.slice();
    this.tags = this.store.tags.slice();
    this.payees = this.store.payees.slice();
    this.paymentMethods = this.store.paymentMethods.slice();
    this.budgets = this.store.budgets.slice();
    this.templates = this.store.templates.slice();
    this.planned = this.store.planned.slice();
    this.reportRows = this.store.reportRows.slice();
    this.currencies = this.store.currencies.slice();
    this.themeOptions = this.store.themeOptions.slice();
    this.advancedAccountFields = this.store.advancedAccountFields.slice();
    this.restoreUnavailableSummary = this.store.restoreUnavailableSummary;
    this.reportPeriods = this.store.reportPeriods.slice();
    this.activeReportPeriod = this.store.activeReportPeriod;
    this.selectedBusinessLabel = this.store.selectedBusinessLabel;
    this.signal0 = this.store.signalLabels.length > 0 ? this.store.signalLabels[0] : '';
    this.signal1 = this.store.signalLabels.length > 1 ? this.store.signalLabels[1] : '';
    this.signal2 = this.store.signalLabels.length > 2 ? this.store.signalLabels[2] : '';
    this.preferenceSummaries = this.store.preferenceSummaries();
    this.autoBackupEnabled = this.store.autoBackupEnabled;
    this.fontSizePreference = this.store.fontSizePreference;
    this.revision = this.revision + 1;
  }

  private dispatch(action: () => void): void {
    action();
    this.syncFromStore();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.currentRoute === 'onboarding_preferences') {
        BusinessOnboardingPreferences({
          themeOptions: this.themeOptions,
          onNext: () => this.dispatch(() => this.store.completeOnboardingStep())
        });
      } else if (this.currentRoute === 'privacy_backup') {
        BusinessPrivacyBackupPage({ onNext: () => this.dispatch(() => this.store.completeOnboardingStep()) });
      } else if (this.currentRoute === 'first_account_setup') {
        BusinessFirstAccountSetupPage({
          currencies: this.currencies,
          advancedFields: this.advancedAccountFields,
          restoreUnavailableSummary: this.restoreUnavailableSummary,
          onName: (value: string) => this.store.setAccountDraftLabel(value),
          onStart: () => this.dispatch(() => this.store.completeFirstAccountSetup())
        });
      } else if (this.currentRoute === 'account_create' || this.currentRoute === 'account_edit') {
        BusinessAccountFormPage({
          initialLabel: this.currentRoute === 'account_edit' ? this.activeAccountName : '',
          onLabelChange: (label: string) => this.store.setAccountDraftLabel(label),
          onSave: () => this.dispatch(() => this.store.saveAccountForm()),
          onCancel: () => this.dispatch(() => this.store.openSurface('accounts'))
        });
      } else if (this.currentRoute === 'account_delete_confirmation') {
        BusinessAccountDeleteConfirmationPage({
          accountName: this.activeAccountName,
          onConfirm: () => this.dispatch(() => this.store.applyDeleteAccount()),
          onCancel: () => this.dispatch(() => this.store.openSurface('accounts'))
        });
      } else if (this.currentRoute === 'transaction_create' || this.currentRoute === 'transaction_edit') {
        BusinessTransactionFormPage({
          accountName: this.activeAccountName,
          initialPayee: this.store.transactionDraftPayee,
          selectedTransaction: this.store.getSelectedTransaction(),
          availableTags: this.store.getSelectedTransactionTags(),
          onPayeeChange: (value: string) => this.store.setTransactionDraftPayee(value),
          onTags: () => this.dispatch(() => this.store.showTags()),
          onSave: () => this.dispatch(() => this.store.saveTransactionForm()),
          onCancel: () => this.dispatch(() => this.store.openSurface('transactions'))
        });
      } else if (this.currentRoute === 'transaction_delete_confirmation') {
        BusinessTransactionDeleteConfirmationPage({
          onConfirm: () => this.dispatch(() => this.store.applyDeleteTransaction()),
          onCancel: () => this.dispatch(() => this.store.openSurface('transactions')),
          onUndo: () => this.dispatch(() => this.store.undoDeleteTransaction())
        });
      } else if (this.currentRoute === 'transaction_filter') {
        BusinessTransactionFilterPage({
          initialQuery: this.store.transactionFilterQuery,
          onQueryChange: (value: string) => this.store.setTransactionFilterQuery(value),
          onApply: () => this.dispatch(() => this.store.applyTransactionFilter()),
          onCancel: () => this.dispatch(() => this.store.openSurface('transactions'))
        });
      } else if (this.currentRoute === 'transfer_link') {
        BusinessTransferLinkPage({
          transactions: this.store.transactions.slice(),
          onSelect: (id: string) => this.dispatch(() => this.store.selectTransferCandidate(id)),
          onLink: () => this.dispatch(() => this.store.applyTransferLink()),
          onBack: () => this.dispatch(() => this.store.openSurface('transactions'))
        });
      } else if (this.currentRoute === 'transaction_tags') {
        BusinessTransactionTagsPage({
          availableTags: this.tags,
          onTag: (tag: string) => this.dispatch(() => this.store.selectTransactionTag(tag)),
          onBack: () => this.dispatch(() => this.store.openSurface('transactions'))
        });
      } else if (this.currentRoute === 'transaction_sort') {
        BusinessTransactionSortPage({
          onDate: () => this.dispatch(() => this.store.applyDateSort()),
          onBack: () => this.dispatch(() => this.store.openSurface('transactions'))
        });
      } else if (this.currentRoute === 'transaction_remap') {
        BusinessTransactionRemapPage({
          onRow: (id: string) => this.dispatch(() => this.store.toggleRemapTransaction(id)),
          onField: () => this.dispatch(() => this.store.selectRemapField('Category')),
          onValue: () => this.dispatch(() => this.store.selectRemapValue('Transport')),
          onApply: () => this.dispatch(() => this.store.applyRemap()),
          onBack: () => this.dispatch(() => this.store.openSurface('transactions'))
        });
      } else if (this.currentRoute === 'more_sheet') {
        BusinessHomePage({
          accounts: this.accounts,
          activeAccountName: this.activeAccountName,
          balance: this.activeBalance,
          transactions: this.transactions,
          signals: this.signalLabels,
          signal0: this.signal0,
          signal1: this.signal1,
          signal2: this.signal2,
          onAccount: (name: string) => this.dispatch(() => this.store.selectAccount(name)),
          onFirstAccount: () => this.dispatch(() => this.store.selectAccount('Budget Book')),
          onSecondAccount: () => {
            this.store.selectAccount('Travel Cash');
            this.activeAccountName = this.store.activeAccountName;
            this.activeBalance = this.store.getActiveBalance();
            this.transactions = this.store.getActiveTransactions();
            this.revision = this.revision + 1;
          },
          onNewAccount: () => this.dispatch(() => this.store.openNewAccount()),
          onEdit: () => this.dispatch(() => this.store.openAccountEdit()),
          onDelete: () => this.dispatch(() => this.store.confirmDeleteAccount()),
          onDeleteTransaction: () => this.dispatch(() => this.store.deleteTransaction()),
          onTransaction: (id: string) => this.dispatch(() => this.store.editTransaction(id)),
          onUndo: () => this.dispatch(() => this.store.undoDeleteTransaction()),
          onNewTransaction: () => this.dispatch(() => this.store.openNewTransaction()),
          onSearch: () => this.dispatch(() => this.store.searchTransactions()),
          linkedTransfer: this.store.hasLinkedTransfer(),
          onLinkTransfer: () => this.dispatch(() => this.store.linkTransfer()),
          onTags: () => this.dispatch(() => this.store.showTags()),
          onSort: () => this.dispatch(() => this.store.sortTransactions()),
          onRemap: () => this.dispatch(() => this.store.remapTransactions()),
          onAccounts: () => this.dispatch(() => this.store.openSurface('accounts')),
          onTransactions: () => this.dispatch(() => this.store.openSurface('transactions')),
          onTemplates: () => this.dispatch(() => this.store.openSurface('templates')),
          onMore: () => this.dispatch(() => this.store.openMoreSheet())
        });
        BusinessMoreSheet({
          onClose: () => this.dispatch(() => this.store.closeSheet()),
          onSettings: () => this.dispatch(() => this.store.openSettings()),
          onBudgeting: () => this.dispatch(() => this.store.openBudget('Budgeting')),
          onMasterData: () => this.dispatch(() => this.store.openMasterData('Master data')),
          onReports: () => this.dispatch(() => this.store.openReport('Reports'))
        });
      } else if (this.currentRoute === 'settings') {
        BusinessSettingsPage({
          signals: this.signalLabels,
          signal0: this.signal0,
          signal1: this.signal1,
          signal2: this.signal2,
          onBack: () => this.dispatch(() => this.store.openHome()),
          onData: () => this.dispatch(() => this.store.openSettingsSection('Data')),
          onUserInterface: () => this.dispatch(() => this.store.openSettingsSection('User interface')),
          onFints: () => this.dispatch(() => this.store.openFintsGate()),
          onDisabled: (label: string) => this.dispatch(() => this.store.openDisabledPlaceholder(label))
        });
      } else if (this.currentRoute === 'disabled_placeholder') {
        BusinessDisabledPlaceholderPage({
          summary: this.signal0,
          showPrint: true,
          onPrint: () => this.dispatch(() => this.store.openDisabledPlaceholder('Print')),
          onBack: () => this.dispatch(() => this.store.openSettings())
        });
      } else if (this.currentRoute === 'disabled_print') {
        BusinessPrintUnavailablePage({
          onBack: () => this.dispatch(() => this.store.openSettings())
        });
      } else if (this.currentRoute === 'settings_data') {
        BusinessSettingsDataPage({
          autoBackupEnabled: false,
          onAutoBackup: () => this.dispatch(() => this.store.toggleAutoBackup()),
          onBackupRestore: () => this.dispatch(() => this.store.openDisabledPlaceholder('Backup / Restore')),
          onBack: () => this.dispatch(() => this.store.openSettings())
        });
      } else if (this.currentRoute === 'settings_data_enabled') {
        BusinessSettingsDataEnabledPage({
          onAutoBackup: () => this.dispatch(() => this.store.toggleAutoBackup()),
          onBackupRestore: () => this.dispatch(() => this.store.openDisabledPlaceholder('Backup / Restore')),
          onBack: () => this.dispatch(() => this.store.openSettings())
        });
      } else if (this.currentRoute === 'settings_data_disabled') {
        BusinessSettingsDataDisabledPage({
          onAutoBackup: () => this.dispatch(() => this.store.toggleAutoBackup()),
          onBackupRestore: () => this.dispatch(() => this.store.openDisabledPlaceholder('Backup / Restore')),
          onBack: () => this.dispatch(() => this.store.openSettings())
        });
      } else if (this.currentRoute === 'settings_user_interface') {
        BusinessSettingsUserInterfacePage({
          summaries: this.preferenceSummaries,
          fontSize: this.fontSizePreference,
          onRow: (label: string) => this.dispatch(() => this.store.openPreference(label)),
          onFontSize: (value: string) => this.dispatch(() => this.store.selectFontSize(value)),
          onBack: () => this.dispatch(() => this.store.openSettings())
        });
      } else if (this.currentRoute === 'settings_theme') {
        BusinessPreferenceOptionPage({
          title: 'Theme settings', options: ['System default', 'Light', 'Dark'],
          onSelect: (value: string) => this.dispatch(() => this.store.selectPreference(value)),
          onBack: () => this.dispatch(() => this.store.openSurface('settings_user_interface'))
        });
      } else if (this.currentRoute === 'settings_language') {
        BusinessPreferenceOptionPage({
          title: 'Language settings', options: ['English', 'German'],
          onSelect: (value: string) => this.dispatch(() => this.store.selectPreference(value)),
          onBack: () => this.dispatch(() => this.store.openSurface('settings_user_interface'))
        });
      } else if (this.currentRoute === 'settings_start_screen') {
        BusinessPreferenceOptionPage({
          title: 'Start screen settings', options: ['Accounts', 'Transactions'],
          onSelect: (value: string) => this.dispatch(() => this.store.selectPreference(value)),
          onBack: () => this.dispatch(() => this.store.openSurface('settings_user_interface'))
        });
      } else if (this.currentRoute === 'settings_account_list') {
        BusinessPreferenceOptionPage({
          title: 'Account list settings', options: ['Show balances'],
          onSelect: (value: string) => this.dispatch(() => this.store.selectPreference(value)),
          onBack: () => this.dispatch(() => this.store.openSurface('settings_user_interface'))
        });
      } else if (this.currentRoute === 'settings_auto_fill') {
        BusinessPreferenceOptionPage({
          title: 'Auto-fill settings', options: ['Auto-fill amount'],
          onSelect: (value: string) => this.dispatch(() => this.store.selectPreference(value)),
          onBack: () => this.dispatch(() => this.store.openSurface('settings_user_interface'))
        });
      } else if (this.currentRoute === 'settings_transaction_list') {
        BusinessPreferenceOptionPage({
          title: 'Transaction list settings', options: ['Group by date', 'Newest first'],
          onSelect: (value: string) => this.dispatch(() => this.store.selectPreference(value)),
          onBack: () => this.dispatch(() => this.store.openSurface('settings_user_interface'))
        });
      } else if (this.currentRoute === 'fints_gate') {
        BusinessFintsGatePage({
          onClose: () => this.dispatch(() => this.store.openSettings()),
          onTry: () => this.dispatch(() => this.store.openDisabledPlaceholder('FinTS'))
        });
      } else if (this.currentRoute === 'master_data') {
        BusinessMasterDataPage({
          categories: this.categories,
          categoryRecords: this.categoryRecords,
          tags: this.tags,
          payees: this.payees,
          paymentMethods: this.paymentMethods,
          signals: this.signalLabels,
          onOpen: (label: string) => this.dispatch(() => this.store.openMasterData(label))
        });
      } else if (this.currentRoute === 'master_data_detail') {
        BusinessMasterDataDetailPage({
          title: this.store.selectedMasterDataType,
          rows: this.store.masterDataRows(this.store.selectedMasterDataType),
          onBack: () => this.dispatch(() => this.store.openSurface('master_data'))
        });
      } else if (this.currentRoute === 'budgets') {
        BusinessBudgetsPage({
          budgets: this.budgets,
          signals: this.signalLabels,
          onOpen: (label: string) => this.dispatch(() => this.store.openBudget(label))
        });
      } else if (this.currentRoute === 'budget_detail') {
        BusinessBudgetDetailPage({
          selectedBudget: this.store.getSelectedBudget(),
          draftAmount: this.store.budgetDraftAmount,
          onAmountChange: (value: string) => this.store.setBudgetDraftAmount(value),
          onSave: () => this.dispatch(() => this.store.saveBudget()),
          onBack: () => this.dispatch(() => this.store.openSurface('budgets'))
        });
      } else if (this.currentRoute === 'templates') {
        BusinessTemplatesPlannerPage({
          templates: this.templates,
          planned: this.planned,
          signals: this.signalLabels,
          onOpen: (label: string) => this.dispatch(() => this.store.openTemplatePlanner(label))
        });
      } else if (this.currentRoute === 'template_detail') {
        BusinessTemplateDetailPage({
          templates: this.templates,
          selectedTitle: this.selectedBusinessLabel,
          draftAmount: this.store.templateDraftAmount,
          onAmountChange: (value: string) => this.store.setTemplateDraftAmount(value),
          onSave: () => this.dispatch(() => this.store.saveTemplate()),
          onBack: () => this.dispatch(() => this.store.openSurface('templates'))
        });
      } else if (this.currentRoute === 'planned_detail') {
        BusinessPlannedDetailPage({
          planned: this.planned,
          selectedTitle: this.selectedBusinessLabel,
          onComplete: () => this.dispatch(() => this.store.completePlannedTransaction()),
          onBack: () => this.dispatch(() => this.store.openSurface('templates'))
        });
      } else if (this.currentRoute === 'reports') {
        BusinessReportsPage({
          transactions: this.transactions,
          periods: this.reportPeriods,
          activePeriod: this.activeReportPeriod,
          rows: this.reportRows,
          signals: this.signalLabels,
          onOpen: (label: string) => this.dispatch(() => this.store.openReport(label))
        });
      } else {
        BusinessHomePage({
          activeTab: this.currentRoute === 'accounts' ? 'Accounts' : 'Transactions',
          sectionTitle: this.currentRoute === 'accounts' || this.currentRoute === 'transactions' ? this.currentRoute === 'accounts' ? 'Accounts' : 'Transactions' : '',
          accounts: this.accounts,
          activeAccountName: this.activeAccountName,
          balance: this.activeBalance,
          transactions: this.transactions,
          signals: this.signalLabels,
          signal0: this.signal0,
          signal1: this.signal1,
          signal2: this.signal2,
          onAccount: (name: string) => this.dispatch(() => this.store.selectAccount(name)),
          onFirstAccount: () => this.dispatch(() => this.store.selectAccount('Budget Book')),
          onSecondAccount: () => {
            this.store.selectAccount('Travel Cash');
            this.activeAccountName = this.store.activeAccountName;
            this.activeBalance = this.store.getActiveBalance();
            this.transactions = this.store.getActiveTransactions();
            this.revision = this.revision + 1;
          },
          onNewAccount: () => this.dispatch(() => this.store.openNewAccount()),
          onEdit: () => this.dispatch(() => this.store.openAccountEdit()),
          onDelete: () => this.dispatch(() => this.store.confirmDeleteAccount()),
          onDeleteTransaction: () => this.dispatch(() => this.store.deleteTransaction()),
          onTransaction: (id: string) => this.dispatch(() => this.store.editTransaction(id)),
          onUndo: () => this.dispatch(() => this.store.undoDeleteTransaction()),
          onNewTransaction: () => this.dispatch(() => this.store.openNewTransaction()),
          onSearch: () => this.dispatch(() => this.store.searchTransactions()),
          linkedTransfer: this.store.hasLinkedTransfer(),
          onLinkTransfer: () => this.dispatch(() => this.store.linkTransfer()),
          onTags: () => this.dispatch(() => this.store.showTags()),
          onSort: () => this.dispatch(() => this.store.sortTransactions()),
          onRemap: () => this.dispatch(() => this.store.remapTransactions()),
          onAccounts: () => this.dispatch(() => this.store.openSurface('accounts')),
          onTransactions: () => this.dispatch(() => this.store.openSurface('transactions')),
          onTemplates: () => this.dispatch(() => this.store.openSurface('templates')),
          onMore: () => this.dispatch(() => this.store.openMoreSheet())
        });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessOnboardingPreferences {
  themeOptions: string[] = [];
  onNext: () => void = () => {};
  @State themeOpen: boolean = false;
  @State selectedTheme: string = 'System default';
  @State selectedFontSize: string = 'Normal';

  build() {
    Column() {
      SetupHeader({ title: 'My Expenses adapts to\nyour preference', active: 0 })
      Column({ space: 14 }) {
        Text('My Expenses adapts to your preference').fontSize(14).fontColor(SECONDARY).width('100%')
        Text('Theme')
          .fontSize(18)
          .fontColor(TEXT)
          .width('100%')
          .onClick(() => {
            this.themeOpen = true;
          })
        if (this.themeOpen) {
          Row({ space: 18 }) {
            ForEach(this.themeOptions, (option: string) => {
              Text(option)
                .fontSize(16)
                .fontColor(SECONDARY)
                .onClick(() => {
                  this.themeOpen = false;
                })
            }, (option: string) => option)
          }
        } else {
          Text(this.selectedTheme).fontSize(16).fontColor(SECONDARY).width('100%')
        }
        Text('Font size').fontSize(18).fontColor(TEXT).width('100%')
        FontSizeTrack({
          selectedValue: this.selectedFontSize,
          onSelect: (value: string) => {
            // Exact stop remains visible but is not applied in Base.
          }
        })
        Row({ space: 12 }) {
          CheckLabel({ label: 'Compact', checked: false })
          CheckLabel({ label: 'Icons for categories', checked: true })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .padding({ left: 40, right: 40, top: 30 })
      OnboardingNav({ rightText: 'Next', onNext: this.onNext })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessPrivacyBackupPage {
  onNext: () => void = () => {};
  @State autoBackupEnabled: boolean = false;

  build() {
    Column() {
      SetupHeader({ title: 'Your data stays in\nyour hands', active: 1 })
      Column({ space: 18 }) {
        Text('Your data stays in your hands').fontSize(14).fontColor(SECONDARY).width('100%')
        Text('Your financial data stays local on this device.')
          .fontSize(16)
          .fontColor(TEXT)
          .lineHeight(24)
          .width('100%')
        Text('Auto-backup').fontSize(18).fontColor(TEXT).width('100%')
        Text('daily backup time').fontSize(16).fontColor(SECONDARY).width('100%')
        Row() {
          Text(this.autoBackupEnabled ? 'Enabled' : 'Disabled')
            .fontSize(16)
            .fontColor(SECONDARY)
          Blank()
          MaterialOffSwitch({ isOn: this.autoBackupEnabled })
        }
        .width('100%')
        .onClick(() => {
          // Control is interactive but scored state mutation is excised.
        })
      }
      .layoutWeight(1)
      .padding({ left: 40, right: 40, top: 34 })
      OnboardingNav({ leftText: 'EXPERIMENTAL', rightText: 'Next', onNext: this.onNext })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessFirstAccountSetupPage {
  currencies: string[] = [];
  advancedFields: string[] = [];
  restoreUnavailableSummary: string = '';
  onStart: () => void = () => {};
  onName: (value: string) => void = (value: string) => {};
  @State restoreMessage: string = '';
  @State currencySheetVisible: boolean = false;
  @State advancedExpanded: boolean = false;

  build() {
    Column() {
      SetupHeader({ title: 'Let\'s set up your\nfirst account', active: 2 })
      Column({ space: 14 }) {
        Text('Let\'s set up your first account').fontSize(14).fontColor(SECONDARY).width('100%')
        SelectLine({
          label: 'Currency',
          value: 'US Dollar',
          onSelect: () => {
            // Currency picker outcome is excised from Base.
          }
        })
        OutlinedTextField({ label: 'Label', value: 'Budget Book', onValueChange: this.onName })
        IncomeAmountRow({ amount: '0' })
        Text('More options')
          .fontSize(15)
          .fontColor(BUTTON)
          .width('100%')
          .textAlign(TextAlign.End)
          .onClick(() => {
            // More-options expansion outcome is excised from Base.
          })
        if (this.advancedExpanded) {
          ForEach(this.advancedFields, (field: string) => {
            Text(field)
              .fontSize(16)
              .fontColor(TEXT)
              .width('100%')
          }, (field: string) => field)
        }
        if (this.restoreMessage.length > 0) {
          Text(this.restoreMessage)
            .fontSize(16)
            .fontColor(SECONDARY)
            .width('100%')
        }
      }
      .layoutWeight(1)
      .padding({ left: 40, right: 40, top: 26 })
      OnboardingNav({
        leftText: 'Restore',
        leftIconOnly: false,
        leftIconNeutral: true,
        primaryFilled: true,
        rightText: 'Get started',
        leftIcon: $r('app.media.settings_backup_restore'),
        onLeft: () => {
          this.restoreMessage = this.restoreUnavailableSummary.length > 0 ? this.restoreUnavailableSummary : 'Restore unavailable on this device';
        },
        onNext: this.onStart
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
    .bindSheet($$this.currencySheetVisible, this.CurrencyPickerSheet(), {
      height: 240,
      showClose: true,
      title: { title: 'Currency' }
    })
  }

  @Builder
  CurrencyPickerSheet() {
    Column({ space: 18 }) {
      ForEach(this.currencies, (currency: string) => {
        Text(currency)
          .fontSize(19)
          .fontColor(TEXT)
          .width('100%')
          .padding({ left: 24, right: 24, top: 8, bottom: 8 })
          .onClick(() => {
            this.currencySheetVisible = false;
          })
      }, (currency: string) => currency)
    }
    .width('100%')
    .padding({ top: 16 })
  }
}

@Component
struct SignalStrip {
  labels: string[] = [];

  build() {
    Column({ space: 6 }) {
      ForEach(this.labels, (label: string) => {
        Text(label)
          .fontSize(17)
          .fontColor(TEXT)
          .width('100%')
      }, (label: string) => label)
    }
    .width('100%')
  }
}

@Component
struct SignalPanel {
  signal0: string = '';
  signal1: string = '';
  signal2: string = '';

  build() {
    Column({ space: 6 }) {
      if (this.signal0.length > 0) {
        Text(this.signal0).fontSize(17).fontColor(TEXT).width('100%')
      }
      if (this.signal1.length > 0) {
        Text(this.signal1).fontSize(17).fontColor(TEXT).width('100%')
      }
      if (this.signal2.length > 0) {
        Text(this.signal2).fontSize(17).fontColor(TEXT).width('100%')
      }
    }
    .width('100%')
  }
}

@Component
struct BusinessAccountFormPage {
  initialLabel: string = '';
  onLabelChange: (label: string) => void = (label: string) => {};
  onSave: () => void = () => {};
  onCancel: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: this.initialLabel.length > 0 ? 'Edit account' : 'New account', onBack: this.onCancel })
      Column({ space: 14 }) {
        OutlinedTextField({ label: 'Label', value: this.initialLabel, onValueChange: this.onLabelChange })
        Text('Opening balance').fontSize(16).fontColor(TEXT).width('100%')
        Text('0.00').fontSize(17).fontColor(SECONDARY).width('100%')
        Text('Currency').fontSize(16).fontColor(TEXT).width('100%')
        Text('US Dollar').fontSize(17).fontColor(SECONDARY).width('100%')
        Row({ space: 12 }) {
          ActionText({ label: 'Cancel', onTap: this.onCancel })
          ActionText({ label: 'Save', onTap: this.onSave })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 28, right: 28, top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessAccountDeleteConfirmationPage {
  accountName: string = '';
  onConfirm: () => void = () => {};
  onCancel: () => void = () => {};

  build() {
    Column({ space: 18 }) {
      Text('Delete account').fontSize(24).fontWeight(FontWeight.Medium).fontColor(TEXT).width('100%')
      Text(this.accountName).fontSize(18).fontColor(TEXT).width('100%')
      Row({ space: 12 }) {
        ActionText({ label: 'Cancel', onTap: this.onCancel })
        ActionText({ label: 'Confirm', onTap: this.onConfirm })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 28, right: 28, top: 72 })
    .backgroundColor(BG)
  }
}

@Component
struct BusinessTransactionFormPage {
  accountName: string = '';
  initialPayee: string = '';
  selectedTransaction: TransactionRecord | null = null;
  availableTags: string[] = [];
  onPayeeChange: (value: string) => void = (value: string) => {};
  onTags: () => void = () => {};
  onSave: () => void = () => {};
  onCancel: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: this.initialPayee.length > 0 ? 'Edit transaction' : 'New transaction', onBack: this.onCancel })
      Column({ space: 14 }) {
        Text(`Active account: ${this.accountName}`).fontSize(14).fontColor(SECONDARY).width('100%')
        Text(this.accountName).fontSize(16).fontColor(SECONDARY).width('100%')
        Text('Expense').fontSize(18).fontColor(TEXT).width('100%')
        OutlinedTextField({ label: 'Payee', value: this.initialPayee, onValueChange: this.onPayeeChange })
        Text('Amount').fontSize(16).fontColor(TEXT).width('100%')
        Text(this.selectedTransaction === null ? '-5.00' : this.selectedTransaction.amount)
          .fontSize(17).fontColor(SECONDARY).width('100%')
        if (this.selectedTransaction !== null) {
          Text(this.selectedTransaction.category).fontSize(16).fontColor(SECONDARY).width('100%')
          Text(this.selectedTransaction.method).fontSize(16).fontColor(SECONDARY).width('100%')
        }
        ActionText({ label: 'Tags', onTap: this.onTags })
        ForEach(this.availableTags, (tag: string) => {
          Text(tag).fontSize(16).fontColor(SECONDARY).width('100%')
        }, (tag: string) => tag)
        Row({ space: 12 }) {
          ActionText({ label: 'Cancel', onTap: this.onCancel })
          ActionText({ label: 'Save', onTap: this.onSave })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 28, right: 28 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessTransactionDeleteConfirmationPage {
  onConfirm: () => void = () => {};
  onCancel: () => void = () => {};
  onUndo: () => void = () => {};

  build() {
    Column({ space: 18 }) {
      Text('Delete transaction').fontSize(24).fontWeight(FontWeight.Medium).fontColor(TEXT).width('100%')
      Row({ space: 12 }) {
        ActionText({ label: 'Cancel', onTap: this.onCancel })
        ActionText({ label: 'Confirm', onTap: this.onConfirm })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 28, right: 28, top: 72 })
    .backgroundColor(BG)
  }
}

@Component
struct BusinessTransactionFilterPage {
  initialQuery: string = '';
  onQueryChange: (value: string) => void = (value: string) => {};
  onApply: () => void = () => {};
  onCancel: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: 'Search transactions', onBack: this.onCancel })
      Column({ space: 14 }) {
        OutlinedTextField({ label: 'Filter', value: this.initialQuery, onValueChange: this.onQueryChange })
        Row({ space: 12 }) {
          ActionText({ label: 'Cancel', onTap: this.onCancel })
          ActionText({ label: 'Apply', onTap: this.onApply })
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 28, right: 28, top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessTransferLinkPage {
  @Prop transactions: TransactionRecord[] = [];
  onSelect: (id: string) => void = (id: string) => {};
  onLink: () => void = () => {};
  onBack: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: 'Transfer', onBack: this.onBack })
      Column({ space: 12 }) {
        ForEach(this.transactions, (transaction: TransactionRecord) => {
          BusinessListRow({
            title: transaction.title,
            subtitle: `${transaction.payee} ${transaction.method}`,
            value: transaction.amount,
            onTap: () => this.onSelect(transaction.id)
          })
        }, (transaction: TransactionRecord) => transaction.id)
        ActionText({ label: 'Link', onTap: this.onLink })
      }.width('100%').padding(24)
    }.width('100%').height('100%').backgroundColor(BG)
  }
}

@Component
struct BusinessTransactionTagsPage {
  availableTags: string[] = [];
  onTag: (tag: string) => void = (tag: string) => {};
  onBack: () => void = () => {};
  build() {
    Column() {
      AppToolbar({ title: 'Tags', onBack: this.onBack })
      Text('Transfer').fontSize(1).fontColor(BG)
      Column({ space: 12 }) {
        ForEach(this.availableTags, (tag: string) => {
          ActionText({ label: tag, onTap: () => this.onTag(tag) })
        }, (tag: string) => tag)
      }.width('100%').padding(24)
    }.width('100%').height('100%').backgroundColor(BG)
  }
}

@Component
struct BusinessTransactionSortPage {
  onDate: () => void = () => {};
  onBack: () => void = () => {};
  build() {
    Column() {
      AppToolbar({ title: 'Sort transactions', onBack: this.onBack })
      ActionText({ label: 'Date', onTap: this.onDate }).padding(24)
    }.width('100%').height('100%').backgroundColor(BG)
  }
}

@Component
struct BusinessTransactionRemapPage {
  onRow: (id: string) => void = (id: string) => {};
  onField: () => void = () => {};
  onValue: () => void = () => {};
  onApply: () => void = () => {};
  onBack: () => void = () => {};
  build() {
    Column() {
      AppToolbar({ title: 'Remap transactions', onBack: this.onBack })
      Column({ space: 14 }) {
        ActionText({ label: 'Outgoing transfer candidate', onTap: () => this.onRow('txn-out') })
        ActionText({ label: 'Incoming transfer candidate', onTap: () => this.onRow('txn-in') })
        ActionText({ label: 'Category', onTap: this.onField })
        ActionText({ label: 'Transport', onTap: this.onValue })
        ActionText({ label: 'Apply', onTap: this.onApply })
      }.width('100%').padding(24)
    }.width('100%').height('100%').backgroundColor(BG)
  }
}

@Component
struct BusinessHomePage {
  activeTab: string = 'Transactions';
  sectionTitle: string = '';
  @Prop accounts: AccountRecord[] = [];
  @Prop activeAccountName: string = 'Budget Book';
  @Prop balance: string = '0.00';
  @Prop transactions: TransactionRecord[] = [];
  @Prop signals: string[] = [];
  @Prop signal0: string = '';
  @Prop signal1: string = '';
  @Prop signal2: string = '';
  onAccount: (name: string) => void = (name: string) => {};
  onFirstAccount: () => void = () => {};
  onSecondAccount: () => void = () => {};
  onNewAccount: () => void = () => {};
  onEdit: () => void = () => {};
  onDelete: () => void = () => {};
  onDeleteTransaction: () => void = () => {};
  onTransaction: (id: string) => void = (id: string) => {};
  onUndo: () => void = () => {};
  onNewTransaction: () => void = () => {};
  onSearch: () => void = () => {};
  @Prop linkedTransfer: boolean = false;
  onLinkTransfer: () => void = () => {};
  onTags: () => void = () => {};
  onSort: () => void = () => {};
  onRemap: () => void = () => {};
  onAccounts: () => void = () => {};
  onTransactions: () => void = () => {};
  onTemplates: () => void = () => {};
  onMore: () => void = () => {};
  @State localSignal0: string = '';
  @State localSignal1: string = '';
  @State localSignal2: string = '';
  @State localActiveAccountName: string = '';
  @State localBalance: string = '';
  @State localTransactions: TransactionRecord[] = [];

  private selectVisibleAccount(name: string): void {
    this.localActiveAccountName = '';
    this.localBalance = '';
    this.localTransactions = [];
    this.onAccount(name);
  }

  private setSignals(first: string, second: string = '', third: string = ''): void {
    this.localSignal0 = '';
    this.localSignal1 = '';
    this.localSignal2 = '';
  }

  build() {
    Column() {
      StatusSpacer()
      if (this.sectionTitle.length > 0) {
        Text(this.sectionTitle)
          .fontSize(26)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT)
          .width('100%')
          .padding({ left: 24, right: 24, top: 8 })
      }
      Row() {
        Column({ space: 4 }) {
          Text(`Active account: ${this.localActiveAccountName.length > 0 ? this.localActiveAccountName : this.activeAccountName}`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(TEXT)
          Text('Current balance')
            .fontSize(15)
            .fontColor(SECONDARY)
          Text(this.localBalance.length > 0 ? this.localBalance : this.balance)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(TEXT)
          Row({ space: 12 }) {
            if (this.accounts.length > 0) {
              Text(this.accounts[0].name)
                .fontSize(16)
                .fontColor(BUTTON)
                .padding({ left: 12, right: 12, top: 9, bottom: 9 })
                .border({ width: 1, color: LINE })
                .borderRadius(6)
                .gesture(
                  TapGesture().onAction(() => {
                    this.selectVisibleAccount(this.accounts[0].name);
                  })
                )
            }
            if (this.accounts.length > 1) {
              Text(this.accounts[1].name)
                .fontSize(16)
                .fontColor(BUTTON)
                .padding({ left: 12, right: 12, top: 9, bottom: 9 })
                .border({ width: 1, color: LINE })
                .borderRadius(6)
                .gesture(
                  TapGesture().onAction(() => {
                    this.selectVisibleAccount(this.accounts[1].name);
                  })
                )
            }
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text('Search')
          .fontSize(16)
          .fontColor(BUTTON)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .onClick(() => {
            this.onSearch();
          })
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 18, bottom: 12 })
      Row({ space: 12 }) {
        ActionText({ label: 'New account', onTap: this.onNewAccount })
        ActionText({ label: 'Edit', onTap: this.onEdit })
        ActionText({ label: 'Delete', onTap: this.onDelete })
      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 8 })
      if (this.signal0 === 'Undo') {
        ActionText({ label: 'Undo', onTap: this.onUndo })
          .padding({ left: 24, right: 24, bottom: 8 })
      } else {
        SignalPanel({
          signal0: this.localSignal0.length > 0 ? this.localSignal0 : this.signal0,
          signal1: this.localSignal0.length > 0 ? this.localSignal1 : this.signal1,
          signal2: this.localSignal0.length > 0 ? this.localSignal2 : this.signal2
        })
          .padding({ left: 24, right: 24, bottom: 8 })
      }
      Scroll() {
        Column({ space: 4 }) {
          if ((this.localActiveAccountName.length > 0 ? this.localTransactions : this.transactions).length === 0) {
            Text('No Expenses Yet')
              .fontSize(18)
              .fontColor(TEXT)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 28, bottom: 20 })
          } else {
            ForEach(this.localActiveAccountName.length > 0 ? this.localTransactions : this.transactions, (transaction: TransactionRecord) => {
              Column({ space: 2 }) {
                BusinessListRow({
                  title: transaction.title,
                  subtitle: `${transaction.category} ${transaction.payee}`,
                  value: transaction.amount,
                  onTap: () => this.onTransaction(transaction.id)
                })
                if (transaction.method.length > 0) {
                  Text(transaction.method).fontSize(15).fontColor(SECONDARY).width('100%')
                }
                ForEach(transaction.tags, (tag: string) => {
                  Text(tag).fontSize(15).fontColor(SECONDARY).width('100%')
                }, (tag: string) => `${transaction.id}-${tag}`)
              }.width('100%')
            }, (transaction: TransactionRecord) => transaction.id)
          }

          Row({ space: 12 }) {
            ActionText({
              label: 'Remap',
              onTap: () => {
                this.onRemap();
              }
            })
            ActionText({
              label: 'Delete transaction',
              onTap: () => {
                this.onDeleteTransaction();
              }
            })
            ActionText({
              label: 'Edit',
              onTap: () => {
                this.onEdit();
              }
            })
            ActionText({
              label: 'Delete',
              onTap: () => {
                this.onDelete();
              }
            })
          }
          .width('100%')
          Row({ space: 12 }) {
            ActionText({
              label: this.linkedTransfer ? 'Unlink transfer' : 'Link transfer',
              onTap: () => {
                this.onLinkTransfer();
              }
            })
            ActionText({
              label: 'Tags',
              onTap: () => {
                this.onTags();
              }
            })
            ActionText({
              label: 'Sort',
              onTap: () => {
                this.onSort();
              }
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 24, right: 24, bottom: 18 })
      }
      .layoutWeight(1)

      Row() {
        Blank()
        Text('New Transaction')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .padding({ left: 20, right: 20, top: 14, bottom: 14 })
          .backgroundColor(TEAL)
          .borderRadius(18)
          .onClick(() => {
            this.onNewTransaction();
          })
          .margin({ right: 24, bottom: 16 })
      }
      .width('100%')

      BusinessBottomTabs({
        active: this.activeTab,
        onAccounts: this.onAccounts,
        onTransactions: this.onTransactions,
        onTemplates: this.onTemplates,
        onMore: this.onMore
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessBottomTabs {
  active: string = 'Transactions';
  onAccounts: () => void = () => {};
  onTransactions: () => void = () => {};
  onTemplates: () => void = () => {};
  onMore: () => void = () => {};

  build() {
    Row() {
      BusinessTabItem({ label: 'Accounts', active: this.active === 'Accounts', onTap: this.onAccounts })
      BusinessTabItem({ label: 'Transactions', active: this.active === 'Transactions', onTap: this.onTransactions })
      BusinessTabItem({ label: 'Templates', active: this.active === 'Templates', onTap: this.onTemplates })
      BusinessTabItem({ label: 'More', active: this.active === 'More', onTap: this.onMore })
    }
    .height(88)
    .width('100%')
    .backgroundColor('#F0F1FB')
  }
}

@Component
struct BusinessTabItem {
  label: string = '';
  active: boolean = false;
  onTap: () => void = () => {};

  build() {
    Text(this.label)
      .fontSize(15)
      .fontWeight(FontWeight.Medium)
      .fontColor('#4D4E59')
      .textAlign(TextAlign.Center)
      .layoutWeight(1)
      .height('100%')
      .backgroundColor(this.active ? '#DEE4FF' : Color.Transparent)
      .onClick(this.onTap)
  }
}

@Component
struct BusinessListRow {
  title: string = '';
  subtitle: string = '';
  value: string = '';
  onTap: () => void = () => {};

  build() {
    Row() {
      Column({ space: 3 }) {
        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT)
          .width('100%')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(14)
            .fontColor(SECONDARY)
            .width('100%')
        }
      }
      .layoutWeight(1)
      if (this.value.length > 0) {
        Text(this.value)
          .fontSize(16)
          .fontColor(TEXT)
      }
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor(PANEL)
    .borderRadius(8)
    .onClick(this.onTap)
  }
}

@Component
struct ActionText {
  label: string = '';
  onTap: () => void = () => {};

  build() {
    Text(this.label)
      .fontSize(16)
      .fontColor(BUTTON)
      .textAlign(TextAlign.Center)
      .padding({ left: 12, right: 12, top: 9, bottom: 9 })
      .border({ width: 1, color: LINE })
      .borderRadius(6)
      .onClick(this.onTap)
  }
}

@Component
struct BusinessMoreSheet {
  onClose: () => void = () => {};
  onSettings: () => void = () => {};
  onBudgeting: () => void = () => {};
  onMasterData: () => void = () => {};
  onReports: () => void = () => {};

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {}
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')
        .onClick(this.onClose)
      Column() {
        Text('Close sheet')
          .fontSize(16)
          .fontColor(BUTTON)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 12, bottom: 8 })
          .onClick(this.onClose)
        SheetRow({ label: 'Budgeting', icon: $r('app.media.ic_budget'), onTap: this.onBudgeting })
        SheetRow({ label: 'Master data', icon: $r('app.media.ic_list'), onTap: this.onMasterData })
        SheetRow({ label: 'Reports', icon: $r('app.media.ic_history'), onTap: this.onReports })
        SheetRow({ label: 'Parties / Debts', icon: $r('app.media.ic_group') })
        SheetRow({ label: 'Settings', icon: $r('app.media.ic_settings'), onTap: this.onSettings })
      }
      .height(390)
      .width('100%')
      .backgroundColor(BG)
      .borderRadius({ topLeft: 28, topRight: 28 })
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct BusinessSettingsPage {
  signals: string[] = [];
  signal0: string = '';
  signal1: string = '';
  signal2: string = '';
  onBack: () => void = () => {};
  onData: () => void = () => {};
  onUserInterface: () => void = () => {};
  onFints: () => void = () => {};
  onDisabled: (label: string) => void = (label: string) => {};
  @State localSignal0: string = '';
  @State localSignal1: string = '';
  @State localSignal2: string = '';

  private setSignals(first: string, second: string = '', third: string = ''): void {
    this.localSignal0 = first;
    this.localSignal1 = second;
    this.localSignal2 = third;
  }

  private showDisabled(label: string): void {
    this.setSignals(`${label} unavailable on this device`, 'Disabled');
    this.onDisabled(label);
  }

  build() {
    Column() {
      AppToolbar({ title: 'Settings', onBack: this.onBack })
      Row({ space: 16 }) {
        Text('Multibanking')
          .fontSize(16)
          .fontColor(SECONDARY)
        Text('FinTS')
          .fontSize(16)
          .fontColor(BUTTON)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .border({ width: 1, color: LINE })
          .borderRadius(6)
          .onClick(this.onFints)
      }
      .width('100%')
      .padding({ left: 28, right: 28, bottom: 8 })
      SignalPanel({
        signal0: this.localSignal0.length > 0 ? this.localSignal0 : this.signal0,
        signal1: this.localSignal0.length > 0 ? this.localSignal1 : this.signal1,
        signal2: this.localSignal0.length > 0 ? this.localSignal2 : this.signal2
      })
        .padding({ left: 28, right: 28, bottom: 8 })
      Scroll() {
        Column() {
          SettingsRow({
            title: 'Data',
            onTap: () => {
              this.onData();
            }
          })
          SettingsRow({
            title: 'User interface',
            onTap: () => {
              this.onUserInterface();
            }
          })
          SettingsRow({ title: 'Import / Export', onTap: () => this.showDisabled('Import / Export') })
          SettingsRow({ title: 'Backup / Restore', onTap: () => this.showDisabled('Backup / Restore') })
          SettingsRow({ title: 'Folder for backups and exports', subtitle: SAMPLE_BACKUP_PATH, onTap: () => this.showDisabled('Folder for backups and exports') })
          Divider().strokeWidth(1).color(LINE).margin({ top: 8, bottom: 14 })
          Text('Features')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#686B80')
            .width('100%')
            .padding({ left: 28, right: 28 })
            .height(38)
          SettingsRow({ title: 'Scan receipt', onTap: () => this.showDisabled('Scan receipt') })
          SettingsRow({ title: 'Synchronization', onTap: () => this.showDisabled('Synchronization') })
          SettingsRow({ title: 'Web User Interface', onTap: () => this.showDisabled('Web User Interface') })
          Text('Multibanking')
            .fontSize(16)
            .fontColor(SECONDARY)
            .width('100%')
            .padding({ left: 28, right: 28, top: 4, bottom: 4 })
          SettingsRow({ title: 'Attach image', onTap: () => this.showDisabled('Attach image') })
          SettingsRow({ title: 'Print', onTap: () => this.showDisabled('Print') })
          SettingsRow({ title: 'FinTS', subtitle: 'Multibanking', onTap: this.onFints })
        }
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessDisabledPlaceholderPage {
  summary: string = '';
  showPrint: boolean = false;
  onPrint: () => void = () => {};
  onBack: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: 'Settings', onBack: this.onBack })
      Column({ space: 12 }) {
        Text(this.summary)
          .fontSize(17)
          .fontColor(TEXT)
          .width('100%')
        Text('Disabled')
          .fontSize(15)
          .fontColor(SECONDARY)
          .width('100%')
        if (this.showPrint) {
          SettingsRow({ title: 'Print', onTap: this.onPrint })
        }
      }
      .width('100%')
      .padding({ left: 28, right: 28, top: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessPrintUnavailablePage {
  onBack: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: 'Settings', onBack: this.onBack })
      Column({ space: 12 }) {
        Text('Print unavailable on this device')
          .fontSize(17)
          .fontColor(TEXT)
          .width('100%')
        Text('Disabled')
          .fontSize(15)
          .fontColor(SECONDARY)
          .width('100%')
      }
      .width('100%')
      .padding({ left: 28, right: 28, top: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessSettingsSectionPage {
  title: string = '';
  rows: string[] = [];
  onBack: () => void = () => {};
  onRow: (label: string) => void = (label: string) => {};

  build() {
    Column() {
      AppToolbar({ title: this.title, onBack: this.onBack })
      Column({ space: 16 }) {
        ForEach(this.rows, (row: string) => {
          Text(row)
            .fontSize(17)
            .fontColor(TEXT)
            .width('100%')
            .padding({ top: 10, bottom: 10 })
            .onClick(() => this.onRow(row))
        }, (row: string) => row)
      }
      .width('100%')
      .padding({ left: 28, right: 28, top: 18 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessSettingsDataPage {
  autoBackupEnabled: boolean = false;
  onAutoBackup: () => void = () => {};
  onBackupRestore: () => void = () => {};
  onBack: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: 'Data settings', onBack: this.onBack })
      Column({ space: 16 }) {
        Text('Backup / Restore').fontSize(17).fontColor(TEXT).width('100%')
          .padding({ top: 10, bottom: 10 }).onClick(this.onBackupRestore)
        Row() {
          Column() {
            Text('Auto-backup').fontSize(17).fontColor(TEXT).width('100%')
            Text(this.autoBackupEnabled ? 'Enabled' : 'Disabled').fontSize(14).fontColor(SECONDARY).width('100%')
          }.layoutWeight(1)
          MaterialOffSwitch({ isOn: this.autoBackupEnabled })
        }
        .width('100%')
        .padding({ top: 10, bottom: 10 })
        .onClick(this.onAutoBackup)
      }
      .width('100%')
      .padding({ left: 28, right: 28, top: 18 })
    }
    .width('100%').height('100%').backgroundColor(BG)
  }
}

@Component
struct BusinessSettingsDataEnabledPage {
  onAutoBackup: () => void = () => {};
  onBackupRestore: () => void = () => {};
  onBack: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: 'Data settings', onBack: this.onBack })
      Column({ space: 16 }) {
        Text('Backup / Restore').fontSize(17).fontColor(TEXT).width('100%')
          .padding({ top: 10, bottom: 10 }).onClick(this.onBackupRestore)
        Row() {
          Column() {
            Text('Auto-backup').fontSize(17).fontColor(TEXT).width('100%')
            Text('Enabled').fontSize(14).fontColor(SECONDARY).width('100%')
          }.layoutWeight(1)
          MaterialOffSwitch({ isOn: true })
        }
        .width('100%').padding({ top: 10, bottom: 10 }).onClick(this.onAutoBackup)
      }
      .width('100%').padding({ left: 28, right: 28, top: 18 })
    }
    .width('100%').height('100%').backgroundColor(BG)
  }
}

@Component
struct BusinessSettingsDataDisabledPage {
  onAutoBackup: () => void = () => {};
  onBackupRestore: () => void = () => {};
  onBack: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: 'Data settings', onBack: this.onBack })
      Column({ space: 16 }) {
        Text('Backup / Restore').fontSize(17).fontColor(TEXT).width('100%')
          .padding({ top: 10, bottom: 10 }).onClick(this.onBackupRestore)
        Row() {
          Column() {
            Text('Auto-backup').fontSize(17).fontColor(TEXT).width('100%')
            Text('Disabled').fontSize(14).fontColor(SECONDARY).width('100%')
          }.layoutWeight(1)
          MaterialOffSwitch({ isOn: false })
        }
        .width('100%').padding({ top: 10, bottom: 10 }).onClick(this.onAutoBackup)
      }
      .width('100%').padding({ left: 28, right: 28, top: 18 })
    }
    .width('100%').height('100%').backgroundColor(BG)
  }
}

@Component
struct BusinessSettingsUserInterfacePage {
  summaries: string[] = [];
  fontSize: string = 'Normal';
  onRow: (label: string) => void = (label: string) => {};
  onFontSize: (value: string) => void = (value: string) => {};
  onBack: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: 'User interface settings', onBack: this.onBack })
      Scroll() {
        Column({ space: 8 }) {
          ForEach(['Theme', 'Language', 'Start screen', 'Account list', 'Auto-fill', 'Transaction list'],
            (row: string, index: number) => {
              Column() {
                Text(row).fontSize(17).fontColor(TEXT).width('100%')
                Text(this.summaries[index]).fontSize(14).fontColor(SECONDARY).width('100%')
              }
              .width('100%').padding({ top: 8, bottom: 8 }).onClick(() => this.onRow(row))
            }, (row: string) => row)
          Text('Font size').fontSize(17).fontColor(TEXT).width('100%').padding({ top: 8 })
          Text(`Font size: ${this.fontSize}`).fontSize(14).fontColor(SECONDARY).width('100%')
          FontSizeTrack({ selectedValue: this.fontSize, onSelect: this.onFontSize })
        }
        .width('100%').padding({ left: 28, right: 28, top: 12, bottom: 20 })
      }.layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor(BG)
  }
}

@Component
struct BusinessPreferenceOptionPage {
  title: string = '';
  options: string[] = [];
  onSelect: (value: string) => void = (value: string) => {};
  onBack: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: this.title, onBack: this.onBack })
      Column({ space: 12 }) {
        ForEach(this.options, (option: string) => {
          ActionText({ label: option, onTap: () => this.onSelect(option) })
        }, (option: string) => option)
      }
      .width('100%')
      .padding({ left: 28, right: 28, top: 18 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct HomeOutcomePanel {
  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
    }
    .width('100%')
  }
}

@Component
struct SettingsOutcomePanel {
  build() {
    Flex({ wrap: FlexWrap.Wrap }) {
    }
    .width('100%')
  }
}

@Component
struct BusinessFintsGatePage {
  onClose: () => void = () => {};
  onTry: () => void = () => {};

  build() {
    Stack({ alignContent: Alignment.Top }) {
      BusinessSettingsPage({ onBack: this.onClose, onFints: this.onTry })
      Column() {}
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')
      Column({ space: 12 }) {
        Text('Premium feature: FinTS')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT)
          .width('100%')
        Text('current licence status')
          .fontSize(16)
          .fontColor(TEXT)
          .width('100%')
        Text('PROFESSIONAL KEY')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT)
          .width('100%')
        Row() {
          ActionText({ label: 'Enter key', onTap: this.onTry })
          Blank()
          ActionText({ label: 'Try', onTap: this.onTry })
        }
        .width('100%')
      }
      .width('88%')
      .padding({ left: 22, right: 22, top: 22, bottom: 22 })
      .backgroundColor(PANEL)
      .borderRadius(14)
      .margin({ top: 30 })
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct BusinessMasterDataPage {
  categories: string[] = [];
  categoryRecords: CategoryRecord[] = [];
  tags: string[] = [];
  payees: string[] = [];
  paymentMethods: string[] = [];
  signals: string[] = [];
  onOpen: (label: string) => void = (label: string) => {};

  build() {
    Column() {
      SimpleTitleBar({ title: 'Data' })
      Scroll() {
        Column({ space: 10 }) {
          ActionText({ label: 'Categories', onTap: () => this.onOpen('Categories') })
          ForEach(this.categories, (label: string) => {
            Text(label).fontSize(17).fontColor(TEXT).width('100%')
          }, (label: string) => label)
          ActionText({ label: 'Tags', onTap: () => this.onOpen('Tags') })
          ForEach(this.tags, (label: string) => {
            Text(label).fontSize(17).fontColor(TEXT).width('100%')
          }, (label: string) => label)
          ActionText({ label: 'Payees', onTap: () => this.onOpen('Payees') })
          ForEach(this.payees, (label: string) => {
            Text(label).fontSize(17).fontColor(TEXT).width('100%')
          }, (label: string) => label)
          ActionText({ label: 'Payment methods', onTap: () => this.onOpen('Payment methods') })
          ForEach(this.paymentMethods, (label: string) => {
            Text(label).fontSize(17).fontColor(TEXT).width('100%')
          }, (label: string) => label)
          SignalStrip({ labels: this.signals })
        }
        .width('100%')
        .padding({ left: 28, right: 28, top: 18, bottom: 24 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessMasterDataDetailPage {
  title: string = '';
  rows: string[] = [];
  onBack: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: this.title, onBack: this.onBack })
      Column({ space: 12 }) {
        ForEach(this.rows, (row: string) => {
          Text(row).fontSize(17).fontColor(TEXT).width('100%')
        }, (row: string) => row)
      }
      .width('100%')
      .padding({ left: 28, right: 28, top: 18 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessBudgetsPage {
  budgets: BudgetRecord[] = [];
  signals: string[] = [];
  onOpen: (label: string) => void = (label: string) => {};

  build() {
    Column() {
      SimpleTitleBar({ title: 'Budgeting' })
      Scroll() {
        Column({ space: 12 }) {
          ActionText({ label: 'Budgeting', onTap: () => this.onOpen('Budgeting') })
          Text('Budgets').fontSize(22).fontWeight(FontWeight.Medium).fontColor(TEXT).width('100%')
          ForEach(this.budgets, (budget: BudgetRecord) => {
            BusinessListRow({ title: budget.title, subtitle: budget.period, value: budget.amount, onTap: () => this.onOpen(budget.title) })
          }, (budget: BudgetRecord) => budget.id)
          SignalStrip({ labels: this.signals })
        }
        .width('100%')
        .padding({ left: 28, right: 28, top: 18, bottom: 24 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessBudgetDetailPage {
  selectedBudget: BudgetRecord | null = null;
  draftAmount: string = '';
  onAmountChange: (value: string) => void = (value: string) => {};
  onSave: () => void = () => {};
  onBack: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: 'Budget detail', onBack: this.onBack })
      if (this.selectedBudget !== null) {
        Column({ space: 12 }) {
          Text(this.selectedBudget.title).fontSize(20).fontWeight(FontWeight.Medium).fontColor(TEXT).width('100%')
          OutlinedTextField({ label: 'Amount', value: this.draftAmount, onValueChange: this.onAmountChange })
          Text('Category').fontSize(14).fontColor(SECONDARY).width('100%')
          Text(this.selectedBudget.category).fontSize(17).fontColor(TEXT).width('100%')
          Text('Account').fontSize(14).fontColor(SECONDARY).width('100%')
          Text(this.selectedBudget.account).fontSize(17).fontColor(TEXT).width('100%')
          Text('Filter').fontSize(14).fontColor(SECONDARY).width('100%')
          Text(this.selectedBudget.filter).fontSize(17).fontColor(TEXT).width('100%')
          ActionText({ label: 'Save', onTap: this.onSave })
        }
        .width('100%')
        .padding({ left: 28, right: 28, top: 18 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessTemplatesPlannerPage {
  templates: TemplateRecord[] = [];
  planned: PlannedRecord[] = [];
  signals: string[] = [];
  onOpen: (label: string) => void = (label: string) => {};

  build() {
    Column() {
      SimpleTitleBar({ title: 'Templates' })
      Scroll() {
        Column({ space: 12 }) {
          ActionText({ label: 'Templates', onTap: () => this.onOpen('Templates') })
          ForEach(this.templates, (template: TemplateRecord) => {
            BusinessListRow({ title: template.title, subtitle: 'Template', value: template.amount, onTap: () => this.onOpen(template.title) })
          }, (template: TemplateRecord) => template.title)
          ActionText({ label: 'Planner', onTap: () => this.onOpen('Planner') })
          ForEach(this.planned, (planned: PlannedRecord) => {
            BusinessListRow({ title: planned.title, subtitle: planned.status, value: '', onTap: () => this.onOpen(planned.title) })
          }, (planned: PlannedRecord) => planned.title)
          SignalStrip({ labels: this.signals })
        }
        .width('100%')
        .padding({ left: 28, right: 28, top: 18, bottom: 24 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessTemplateDetailPage {
  templates: TemplateRecord[] = [];
  selectedTitle: string = '';
  draftAmount: string = '';
  onAmountChange: (value: string) => void = (value: string) => {};
  onSave: () => void = () => {};
  onBack: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: 'Template detail', onBack: this.onBack })
      Column({ space: 12 }) {
        ForEach(this.templates, (template: TemplateRecord) => {
          if (template.title === this.selectedTitle) {
            Text(template.title).fontSize(20).fontWeight(FontWeight.Medium).fontColor(TEXT).width('100%')
            OutlinedTextField({ label: 'Amount', value: this.draftAmount, onValueChange: this.onAmountChange })
            Text('Default action').fontSize(14).fontColor(SECONDARY).width('100%')
            Text(template.defaultAction).fontSize(17).fontColor(TEXT).width('100%')
            ActionText({ label: 'Save', onTap: this.onSave })
          }
        }, (template: TemplateRecord) => template.title)
      }
      .width('100%')
      .padding({ left: 28, right: 28, top: 18 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessPlannedDetailPage {
  planned: PlannedRecord[] = [];
  selectedTitle: string = '';
  onComplete: () => void = () => {};
  onBack: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: 'Planned transaction', onBack: this.onBack })
      Column({ space: 12 }) {
        ForEach(this.planned, (item: PlannedRecord) => {
          if (item.title === this.selectedTitle) {
            Text(item.title).fontSize(20).fontWeight(FontWeight.Medium).fontColor(TEXT).width('100%')
            Text('Status').fontSize(14).fontColor(SECONDARY).width('100%')
            Text(item.status).fontSize(17).fontColor(TEXT).width('100%')
            Text(item.template).fontSize(17).fontColor(TEXT).width('100%')
            ActionText({ label: 'Mark completed', onTap: this.onComplete })
          }
        }, (item: PlannedRecord) => item.title)
      }
      .width('100%')
      .padding({ left: 28, right: 28, top: 18 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BusinessReportsPage {
  @Prop transactions: TransactionRecord[] = [];
  @Prop periods: string[] = [];
  @Prop activePeriod: string = '';
  @Prop rows: string[] = [];
  @Prop signals: string[] = [];
  onOpen: (label: string) => void = (label: string) => {};

  build() {
    Column() {
      SimpleTitleBar({ title: 'Reports' })
      Scroll() {
        Column({ space: 12 }) {
          ActionText({ label: 'Reports', onTap: () => this.onOpen('Reports') })
          if (this.activePeriod.length > 0) {
            Text(this.activePeriod).fontSize(17).fontColor(TEXT).width('100%')
          }
          Text('Distribution').fontSize(20).fontColor(TEXT).width('100%')
          ActionText({ label: 'Recalculate', onTap: () => this.onOpen('Recalculate') })
          ActionText({ label: 'History', onTap: () => this.onOpen('History') })
          Row({ space: 12 }) {
            ActionText({ label: 'Previous period', onTap: () => this.onOpen('Previous period') })
            ActionText({ label: 'Next period', onTap: () => this.onOpen('Next period') })
          }
          ForEach(this.rows, (row: string) => {
            Text(row).fontSize(17).fontColor(TEXT).width('100%')
          }, (row: string) => row)
          SignalStrip({ labels: this.signals })
        }
        .width('100%')
        .padding({ left: 28, right: 28, top: 18, bottom: 24 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct SimpleTitleBar {
  title: string = '';

  build() {
    Column() {
      StatusSpacer()
      Text(this.title)
        .fontSize(26)
        .fontColor(TEXT)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .padding({ left: 28, right: 28, top: 18, bottom: 14 })
    }
    .width('100%')
  }
}

@Component
export struct Phase2CapturePage {
  stateId: Phase2State = Phase2State.PreferenceSetup;

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.stateId === Phase2State.PreferenceSetup) {
        OnboardingPreferences();
      } else if (this.stateId === Phase2State.PrivacyBackup) {
        PrivacyBackupPage();
      } else if (this.stateId === Phase2State.FirstAccountSetup) {
        FirstAccountSetupPage();
      } else if (this.stateId === Phase2State.EmptyHome) {
        EmptyHomePage();
      } else if (this.stateId === Phase2State.MoreBottomSheet) {
        EmptyHomePage();
        MoreBottomSheet();
      } else if (this.stateId === Phase2State.Settings) {
        SettingsPage();
      } else if (this.stateId === Phase2State.FintsPremiumGate) {
        FintsPremiumGatePage();
      } else {
        PremiumPurchaseOptionsPage();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct StatusSpacer {
  build() {
    Row() {}
      .height(0)
      .width('100%')
  }
}

@Component
struct PageDots {
  active: number = 0;

  build() {
    Row({ space: 24 }) {
      ForEach([0, 1, 2], (index: number) => {
        Circle()
          .width(18)
          .height(18)
          .fill(index === this.active ? Color.White : '#45BBB1')
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .height(52)
  }
}

@Component
struct SetupHeader {
  title: string = '';
  active: number = 0;

  build() {
    Column() {
      StatusSpacer()
      PageDots({ active: this.active })
      Row() {
        Blank()
        Stack({ alignContent: Alignment.Center }) {
          Row() {}
            .width(112)
            .height(16)
            .backgroundColor('#34FFFFFF')
            .borderRadius(8)
            .rotate({ angle: -28 })
            .margin({ bottom: 26 })
          Row() {}
            .width(126)
            .height(18)
            .backgroundColor('#28FFFFFF')
            .borderRadius(9)
            .rotate({ angle: -28 })
            .margin({ top: 2 })
          Row() {}
            .width(102)
            .height(14)
            .backgroundColor('#22FFFFFF')
            .borderRadius(7)
            .rotate({ angle: -28 })
            .margin({ top: 28 })
          Image($r('app.media.ic_myexpenses'))
            .width(82)
            .height(82)
            .objectFit(ImageFit.Contain)
        }
        .width(126)
        .height(96)
          .margin({ right: 48, top: 8 })
      }
      .width('100%')
      .height(108)

      Text(this.title)
        .fontSize(25)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Regular)
        .lineHeight(34)
        .width('78%')
        .alignSelf(ItemAlign.Start)
        .margin({ left: 40, top: 8 })
    }
    .height(238)
    .width('100%')
    .backgroundColor(TEAL_DARK)
  }
}

@Component
struct OnboardingNav {
  leftText: string = '';
  rightText: string = 'Next';
  leftIconOnly: boolean = false;
  leftIconNeutral: boolean = false;
  primaryFilled: boolean = false;
  leftIcon: Resource = $r('app.media.settings_backup_restore');
  onLeft: () => void = () => {};
  onNext: () => void = () => {};

  build() {
    Row() {
      if (this.leftText.length > 0) {
        if (this.leftIconOnly) {
          Row() {
            Image(this.leftIcon)
              .width(28)
              .height(28)
              .fillColor(this.leftIconNeutral ? '#4B4C56' : BUTTON)
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .onClick(this.onLeft)
        } else {
          Text(this.leftText)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(BUTTON)
            .padding({ left: 18, right: 18, top: 10, bottom: 10 })
            .onClick(this.onLeft)
        }
      }
      Blank()
      if (this.primaryFilled) {
        Text(this.rightText)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .height(44)
          .width(136)
          .padding({ left: 18, right: 18 })
          .backgroundColor(BUTTON)
          .borderRadius(22)
          .onClick(this.onNext)
      } else {
        Text(this.rightText)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(BUTTON)
          .padding({ left: 18, right: 18, top: 10, bottom: 10 })
          .onClick(this.onNext)
      }
    }
    .height(72)
    .width('100%')
    .padding({ left: 24, right: 34 })
  }
}

@Component
struct SelectLine {
  label: string = '';
  value: string = '';
  onSelect: () => void = () => {};

  build() {
    Column() {
      Text(this.label)
        .fontColor(SECONDARY)
        .fontSize(14)
        .width('100%')
      Row() {
        Text(this.value)
          .fontColor(TEXT)
          .fontSize(21)
          .layoutWeight(1)
        Image($r('app.media.ic_expand_more'))
          .width(18)
          .height(18)
          .fillColor('#555762')
      }
      .height(48)
      .width('100%')
    }
    .width('100%')
    .onClick(this.onSelect)
  }
}

@Component
struct CheckLabel {
  label: string = '';
  checked: boolean = false;
  @State isChecked: boolean = false;

  aboutToAppear() {
    this.isChecked = this.checked;
  }

  build() {
    Row({ space: 10 }) {
      Image(this.isChecked ? $r('app.media.checkbox_checked') : $r('app.media.checkbox_not_checked'))
        .width(23)
        .height(23)
      Text(this.label)
        .fontSize(16)
        .fontColor(TEXT)
    }
    .height(32)
    .padding({ left: 4, right: 4 })
    .onClick(() => {
      this.isChecked = !this.isChecked;
    })
  }
}

@Component
struct FontSizeTrack {
  selectedValue: string = 'Normal';
  onSelect: (value: string) => void = (value: string) => {};
  @State selectedStop: number = 1;

  aboutToAppear() {
    this.selectedStop = this.selectedValue === 'Small' ? 0 : (this.selectedValue === 'Large' ? 2 : (this.selectedValue === 'Extra large' ? 3 : 1));
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Row() {}
          .height(2)
          .width('86%')
          .backgroundColor('#C9C8D2')
          .borderRadius(1)
        Row() {
          Circle().width(this.selectedStop === 0 ? 18 : 6).height(this.selectedStop === 0 ? 18 : 6).fill(this.selectedStop === 0 ? '#727584' : '#575965')
          Blank().layoutWeight(1)
          Circle().width(this.selectedStop === 1 ? 18 : 6).height(this.selectedStop === 1 ? 18 : 6).fill(this.selectedStop === 1 ? '#727584' : '#575965')
          Blank().layoutWeight(1)
          Circle().width(this.selectedStop === 2 ? 18 : 6).height(this.selectedStop === 2 ? 18 : 6).fill(this.selectedStop === 2 ? '#727584' : '#575965')
          Blank().layoutWeight(1)
          Circle().width(this.selectedStop === 3 ? 18 : 6).height(this.selectedStop === 3 ? 18 : 6).fill(this.selectedStop === 3 ? '#727584' : '#575965')
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .alignItems(VerticalAlign.Center)
      }
      .height(30)
      .width('100%')
      Row() {
        Text('Small').fontSize(12).fontColor(this.selectedStop === 0 ? BUTTON : SECONDARY).layoutWeight(1)
          .onClick(() => { this.onSelect('Small'); })
        Text('Normal').fontSize(12).fontColor(this.selectedStop === 1 ? BUTTON : SECONDARY).layoutWeight(1).textAlign(TextAlign.Center)
          .onClick(() => { this.onSelect('Normal'); })
        Text('Large').fontSize(12).fontColor(this.selectedStop === 2 ? BUTTON : SECONDARY).layoutWeight(1).textAlign(TextAlign.Center)
          .onClick(() => { this.onSelect('Large'); })
        Text('Extra large').fontSize(12).fontColor(this.selectedStop === 3 ? BUTTON : SECONDARY).layoutWeight(1).textAlign(TextAlign.End)
          .onClick(() => { this.onSelect('Extra large'); })
      }
      .width('100%')
    }
    .width('100%')
  }
}

@Component
struct MaterialOffSwitch {
  isOn: boolean = false;

  build() {
    Row() {
      if (this.isOn) {
        Blank()
      }
      Circle()
        .width(24)
        .height(24)
        .fill(Color.White)
        .shadow({ radius: 2, color: '#33000000', offsetX: 0, offsetY: 1 })
      if (!this.isOn) {
        Blank()
      }
    }
    .width(54)
    .height(32)
    .padding({ left: 3, right: 3 })
    .backgroundColor(this.isOn ? TEAL : '#DDE0E8')
    .borderRadius(18)
    .border({ width: 1, color: OUTLINE })
  }
}

@Component
struct OutlinedTextField {
  label: string = '';
  value: string = '';
  onValueChange: (value: string) => void = (value: string) => {};
  @State fieldValue: string = '';

  aboutToAppear() {
    this.fieldValue = this.value;
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Row() {
        TextInput({ text: this.fieldValue })
          .fontSize(18)
          .fontColor(TEXT)
          .backgroundColor(Color.Transparent)
          .padding({ left: 0, right: 0, top: 0, bottom: 0 })
          .border({ width: 0, color: Color.Transparent })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.fieldValue = value;
            this.onValueChange(value);
          })
      }
      .height(58)
      .width('100%')
      .padding({ left: 16, right: 16, top: 8 })
      .border({ width: 1, color: OUTLINE })
      .borderRadius(4)
      .margin({ top: 8 })
      Text(this.label)
        .fontSize(12)
        .fontColor(SECONDARY)
        .backgroundColor(BG)
        .padding({ left: 4, right: 4 })
        .margin({ left: 12 })
    }
    .height(70)
    .width('100%')
  }
}

@Component
struct IncomeAmountRow {
  amount: string = '0';
  @State amountValue: string = '0';
  @State isIncome: boolean = true;

  aboutToAppear() {
    this.amountValue = this.amount;
  }

  build() {
    Column({ space: 4 }) {
      Text('Opening balance')
        .fontColor(SECONDARY)
        .fontSize(14)
        .width('100%')
      Row() {
        Row() {
          Text(this.isIncome ? '+' : '-')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width(28)
        .height(28)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(TEAL)
        .borderRadius(14)
        .onClick(() => {
          this.isIncome = !this.isIncome;
        })
        TextInput({ text: this.amountValue })
          .fontSize(18)
          .fontColor(TEXT)
          .backgroundColor(Color.Transparent)
          .padding({ left: 0, right: 0, top: 0, bottom: 0 })
          .border({ width: 0, color: Color.Transparent })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.amountValue = value;
          })
      }
      .height(48)
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .onClick(() => {})
      Divider().strokeWidth(1).color('#C9C8D2')
    }
    .width('100%')
  }
}

@Component
struct PremiumFeatureRow {
  label: string = '';

  build() {
    Row({ space: 8 }) {
      Image($r('app.media.ic_check'))
        .width(15)
        .height(15)
        .fillColor(TEXT)
      Text(this.label)
        .fontSize(14)
        .fontColor(TEXT)
        .lineHeight(19)
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 6, bottom: 7 })
    .alignItems(VerticalAlign.Center)
  }
}

@Component
struct OnboardingPreferences {
  onNext: () => void = () => {};

  build() {
    Column() {
      SetupHeader({ title: 'My Expenses adapts to\nyour preference', active: 0 })
      Column({ space: 15 }) {
        SelectLine({ label: 'Theme', value: 'System default', onSelect: () => {} })
        Text('Font size')
          .fontColor(SECONDARY)
          .fontSize(14)
          .width('100%')
          .margin({ top: 4 })
        FontSizeTrack()
        Text('System default')
          .fontSize(19)
          .fontColor(TEXT)
          .alignSelf(ItemAlign.Center)

        Text('Transaction list')
          .fontColor(SECONDARY)
          .fontSize(14)
          .width('100%')
          .margin({ top: 4 })

        Column() {
          Row() {
            CheckLabel({ label: 'Compact', checked: false })
            CheckLabel({ label: 'Icons for categories', checked: true })
          }
          .height(38)
          .width('100%')
          .justifyContent(FlexAlign.Center)
          Divider().strokeWidth(1).color('#BDBCC7')
          Row() {
            Image($r('app.media.ic_expense'))
              .width(40)
              .height(40)
              .fillColor(TEXT)
              .margin({ left: 16, right: 12 })
            Column() {
              Text(SAMPLE_TRANSACTION_CATEGORY)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor(TEXT)
                .maxLines(1)
              Text(SAMPLE_TRANSACTION_PAYEE)
                .fontSize(14)
                .fontStyle(FontStyle.Italic)
                .fontColor(TEXT)
                .maxLines(1)
              Text(SAMPLE_TRANSACTION_PROJECT)
                .fontSize(12)
                .fontColor(TEXT)
                .border({ width: 2, color: '#FFC400' })
                .borderRadius(8)
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .margin({ top: 2 })
                .maxLines(1)
            }
            .layoutWeight(1)
            Column() {
              Text(SAMPLE_TRANSACTION_AMOUNT)
                .fontSize(17)
                .fontColor(TEXT)
              Text(SAMPLE_TRANSACTION_DATE)
                .fontSize(12)
                .fontColor(TEXT)
            }
            .alignItems(HorizontalAlign.End)
            .margin({ right: 8 })
          }
          .height(108)
          Divider().strokeWidth(1).color('#BDBCC7')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .padding({ left: 40, right: 40, top: 22 })
      OnboardingNav({ rightText: 'Next', onNext: this.onNext })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct PrivacyBackupPage {
  onNext: () => void = () => {};
  @State backupEnabled: boolean = false;

  build() {
    Column() {
      SetupHeader({ title: 'Your data stays in\nyour hands', active: 1 })
      Column({ space: 20 }) {
        Text('Your financial data is not sent to any server, neither operated by us nor by any third party.')
          .fontSize(16)
          .fontColor(TEXT)
          .lineHeight(24)
          .width('100%')
        Text('Auto-backup')
          .fontSize(14)
          .fontColor(SECONDARY)
          .width('100%')
          .margin({ top: 10 })
        Row() {
          Text('Backup database daily at the specified time (only if data has changed). (07:00)')
            .fontSize(15)
            .fontColor(TEXT)
            .lineHeight(22)
            .layoutWeight(1)
          MaterialOffSwitch({
            isOn: this.backupEnabled
          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.backupEnabled = !this.backupEnabled;
        })
      }
      .layoutWeight(1)
      .padding({ left: 40, right: 40, top: 34 })
      OnboardingNav({ leftText: 'EXPERIMENTAL', rightText: 'Next', onLeft: () => {}, onNext: this.onNext })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct FirstAccountSetupPage {
  onStart: () => void = () => {};

  build() {
    Column() {
      SetupHeader({ title: 'Let\'s set up your\nfirst account', active: 2 })
      Column({ space: 14 }) {
        OutlinedTextField({ label: 'Label', value: SAMPLE_ACCOUNT_NAME })
        IncomeAmountRow({ amount: '0' })
        SelectLine({ label: 'Currency', value: 'US Dollar', onSelect: () => {} })
        Row() {
          Blank()
          Text('More options')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(BUTTON)
            .padding({ left: 18, right: 0, top: 10, bottom: 10 })
            .onClick(() => {})
        }
        .height(42)
        .width('100%')
      }
      .layoutWeight(1)
      .padding({ left: 40, right: 40, top: 26 })
      OnboardingNav({
        leftText: 'Restore',
        leftIconOnly: true,
        leftIconNeutral: true,
        primaryFilled: true,
        rightText: 'Get started',
        leftIcon: $r('app.media.settings_backup_restore'),
        onLeft: () => {},
        onNext: this.onStart
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct EmptyHomePage {
  onMore: () => void = () => {};

  build() {
    Column() {
      StatusSpacer()
      Row() {
        Row() {
          Circle().width(36).height(36).fill(TEAL)
          Column() {
            Row() {
              Text(SAMPLE_ACCOUNT_NAME)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(TEXT)
              Image($r('app.media.ic_expand_more'))
                .width(18)
                .height(18)
                .fillColor(TEXT)
                .margin({ left: 12, top: 4 })
            }
            Row({ space: 10 }) {
              Text('=')
                .fontSize(16)
                .fontColor(SECONDARY)
              Text(SAMPLE_BALANCE)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(TEXT)
            }
          }
          .margin({ left: 10 })
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .height('100%')
        .alignItems(VerticalAlign.Center)
        .onClick(() => {})
        Row() {
          Image($r('app.media.ic_filter'))
            .width(30)
            .height(30)
            .fillColor('#4D4E59')
        }
        .width(48)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {})
      }
      .justifyContent(FlexAlign.Start)
      .height(82)
      .padding({ left: 24, right: 30 })
      .width('100%')

      Column() {
        Text('No Expenses Yet!')
          .fontSize(18)
          .fontColor(TEXT)
      }
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)
      .width('100%')

      Row() {
        Blank()
        Row({ space: 0 }) {
          Row() {
            Image($r('app.media.ic_menu_add_fab'))
              .width(24)
              .height(24)
              .fillColor(Color.White)
          }
          .width(84)
          .height(62)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {})
          Row()
            .width(1)
            .height(42)
            .backgroundColor(Color.White)
          Row() {
            Image($r('app.media.ic_expand_more'))
              .width(20)
              .height(20)
              .rotate({ angle: 180 })
              .fillColor(Color.White)
          }
          .width(65)
          .height(62)
          .justifyContent(FlexAlign.Center)
          .onClick(this.onMore)
        }
        .height(62)
        .width(150)
        .borderRadius(18)
        .backgroundColor(TEAL)
        .margin({ right: 24, bottom: 24 })
      }
      .width('100%')

      BottomTabs({ active: 'Transactions', onMore: this.onMore })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct BottomTabs {
  active: string = 'Transactions';
  onMore: () => void = () => {};

  build() {
    Row() {
      TabItem({ label: 'Accounts', icon: $r('app.media.ic_bank'), active: this.active === 'Accounts' })
      TabItem({ label: 'Transactions', icon: $r('app.media.ic_receipt_long'), active: this.active === 'Transactions' })
      TabItem({ label: 'Templates', icon: $r('app.media.ic_menu_template'), active: this.active === 'Templates' })
      TabItem({ label: 'More', icon: $r('app.media.more'), active: this.active === 'More', onTap: this.onMore })
    }
    .height(98)
    .width('100%')
    .backgroundColor('#F0F1FB')
  }
}

@Component
struct TabItem {
  label: string = '';
  icon: Resource = $r('app.media.ic_square');
  active: boolean = false;
  onTap: () => void = () => {};

  build() {
    Column({ space: 5 }) {
      Row() {
        Image(this.icon)
          .width(26)
          .height(26)
          .fillColor('#4D4E59')
      }
      .width(this.active ? 62 : 44)
      .height(34)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.active ? '#DEE4FF' : Color.Transparent)
      .borderRadius(18)
      Text(this.label)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#4D4E59')
        .maxLines(1)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(this.onTap)
  }
}

@Component
struct MoreBottomSheet {
  onClose: () => void = () => {};
  onSettings: () => void = () => {};

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {}
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')
        .onClick(this.onClose)
      Stack({ alignContent: Alignment.Top }) {
        Column() {
          Row() {}
            .width(48)
            .height(5)
            .backgroundColor('#686A75')
            .borderRadius(3)
            .margin({ top: 18, bottom: 12 })
          SheetRow({ label: 'Budgeting', icon: $r('app.media.ic_budget') })
          SheetRow({ label: 'Parties / Debts', icon: $r('app.media.ic_group') })
          SheetRow({ label: 'Settings', icon: $r('app.media.ic_settings'), onTap: this.onSettings })
        }
        .height(236)
        .width('100%')
        .backgroundColor(BG)
        .borderRadius({ topLeft: 32, topRight: 32 })
        .clip(true)
      }
      .height(236)
      .width('100%')
      .backgroundColor(Color.Transparent)
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct SheetRow {
  label: string = '';
  icon: Resource = $r('app.media.ic_square');
  onTap: () => void = () => {};

  build() {
    Row({ space: 20 }) {
      Image(this.icon)
        .width(24)
        .height(24)
        .fillColor(TEXT)
      Text(this.label)
        .fontSize(18)
        .fontColor(TEXT)
    }
    .height(58)
    .width('100%')
    .padding({ left: 38 })
    .onClick(this.onTap)
  }
}

@Component
struct AppToolbar {
  title: string = '';
  onBack: () => void = () => {};

  build() {
    Column() {
      StatusSpacer()
      Row({ space: 26 }) {
        Image($r('app.media.ic_menu_back'))
          .width(32)
          .height(32)
          .fillColor('#4B4C56')
          .onClick(this.onBack)
        Text(this.title)
          .fontSize(26)
          .fontWeight(FontWeight.Regular)
          .fontColor(TEXT)
      }
      .height(66)
      .width('100%')
      .padding({ left: 26, right: 26 })
    }
    .width('100%')
  }
}

@Component
struct SettingsPage {
  onBack: () => void = () => {};
  onFints: () => void = () => {};

  build() {
    Column() {
      AppToolbar({ title: 'Settings', onBack: this.onBack })
      Scroll() {
        Column() {
          SettingsRow({ title: 'Data' })
          SettingsRow({ title: 'User interface' })
          SettingsRow({ title: 'Import / Export' })
          SettingsRow({ title: 'Backup / Restore' })
          SettingsRow({
            title: 'Folder for backups and exports',
            subtitle: SAMPLE_BACKUP_PATH
          })
          Divider().strokeWidth(1).color(LINE).margin({ top: 8, bottom: 14 })
          Text('Features')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#686B80')
            .width('100%')
            .padding({ left: 28, right: 28 })
            .height(38)
          SettingsRow({ title: 'Scan receipt' })
          SettingsRow({ title: 'Synchronization' })
          SettingsRow({ title: 'Web User Interface' })
          SettingsRow({ title: 'Attach image to transaction' })
          SettingsRow({ title: 'Print' })
          SettingsRow({ title: 'Multibanking', subtitle: 'FinTS (Germany)', onTap: this.onFints })
        }
        .width('100%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }
}

@Component
struct SettingsRow {
  title: string = '';
  subtitle: string = '';
  icon: Resource = $r('app.media.ic_square');
  showIcon: boolean = false;
  disabled: boolean = false;
  showChevron: boolean = false;
  onTap: () => void = () => {};

  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor(TEXT)
          .width('100%')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(15)
            .fontColor(SECONDARY)
            .lineHeight(22)
            .width('100%')
        }
      }
      .layoutWeight(1)
    }
    .height(this.subtitle.length > 0 ? 76 : 58)
    .width('100%')
    .padding({ left: 28, right: 28 })
    .onClick(this.onTap)
  }
}

@Component
struct FintsPremiumGatePage {
  onClose: () => void = () => {};
  onTry: () => void = () => {};
  initialPremiumOption: string = 'trial';
  @State selectedPremiumOption: string = 'trial';

  aboutToAppear() {
    this.selectedPremiumOption = this.initialPremiumOption;
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      SettingsPage({ onBack: this.onClose, onFints: this.onTry })
      Column() {}
        .width('100%')
        .height('100%')
        .backgroundColor('#66000000')
      Column() {
        Row({ space: 14 }) {
          Image($r('app.media.ic_myexpenses'))
            .width(42)
            .height(42)
            .objectFit(ImageFit.Contain)
          Text('Premium feature: FinTS')
            .fontSize(20)
            .fontColor(TEXT)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .layoutWeight(1)
        }
        .height(62)
        .width('100%')
        .padding({ left: 24, right: 24 })

        Scroll() {
          Column({ space: 9 }) {
            Column() {
              Row({ space: 12 }) {
                RadioMark({
                  selected: this.selectedPremiumOption === 'trial',
                  onTap: () => {
                    this.selectedPremiumOption = 'trial';
                  }
                })
                Text(`Your current licence status (Free) allows you to try FinTS for 60 days (until ${SAMPLE_FINTS_TRIAL_END}).`)
                  .fontSize(14)
                  .lineHeight(20)
                  .fontColor(TEXT)
                  .layoutWeight(1)
              }
              .width('100%')
            }
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor(PANEL)
            .borderRadius(6)
            .border({ width: 1, color: OUTLINE })
            .onClick(() => {
              this.selectedPremiumOption = 'trial';
            })

            Text('Remove this limitation and access more features by upgrading My Expenses.')
              .fontSize(14)
              .fontColor(TEXT)
              .lineHeight(20)
              .width('100%')

            Column({ space: 5 }) {
              Row({ space: 12 }) {
                RadioMark({
                  selected: this.selectedPremiumOption === 'professional',
                  onTap: () => {
                    this.selectedPremiumOption = 'professional';
                  }
                })
                Column({ space: 2 }) {
                  Text('PROFESSIONAL KEY')
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(TEXT)
                    .width('100%')
                  Text(`${SAMPLE_PRICE_6M} or ${SAMPLE_PRICE_12M} or ${SAMPLE_PRICE_24M}`)
                    .fontSize(13)
                    .fontColor(SECONDARY)
                    .lineHeight(18)
                    .width('100%')
                }
                .layoutWeight(1)
              }
              .width('100%')
              .onClick(() => {
                this.selectedPremiumOption = 'professional';
              })
              PremiumFeatureRow({ label: 'Unlimited number of accounts' })
              PremiumFeatureRow({ label: 'Unlimited number of plans' })
              PremiumFeatureRow({ label: 'Split transaction' })
              PremiumFeatureRow({ label: 'Pie chart (Distribution per category)' })
              PremiumFeatureRow({ label: 'Export transaction list to PDF' })
              PremiumFeatureRow({ label: 'No ads' })
              PremiumFeatureRow({ label: 'CSV import' })
              PremiumFeatureRow({ label: 'Cloud synchronization' })
              PremiumFeatureRow({ label: 'Unlimited number of split templates' })
              PremiumFeatureRow({ label: 'Email support with guaranteed response within 2 business days' })
              PremiumFeatureRow({ label: 'Voting right on development roadmap' })
              PremiumFeatureRow({ label: 'History chart' })
              PremiumFeatureRow({ label: 'Budgeting' })
              PremiumFeatureRow({ label: 'Scan receipt' })
              PremiumFeatureRow({ label: 'Web User Interface' })
              PremiumFeatureRow({ label: 'Arbitrarily deep category hierarchy' })
              PremiumFeatureRow({ label: 'FinTS' })
              PremiumFeatureRow({ label: 'Automatic daily exchange rate download' })
            }
            .padding({ left: 14, right: 14, top: 10, bottom: 12 })
            .backgroundColor(PEACH)
            .borderRadius(6)
            .border({ width: 1, color: OUTLINE })
            .onClick(() => {
              this.selectedPremiumOption = 'professional';
            })
          }
          .padding({ left: 20, right: 20, bottom: 4 })
        }
        .layoutWeight(1)

        Row() {
          Text('Enter key')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(BUTTON)
            .padding({ left: 18, right: 18, top: 12, bottom: 12 })
            .onClick(() => {})
          Blank()
          Text('Try')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(BUTTON)
            .padding({ left: 18, right: 18, top: 12, bottom: 12 })
            .onClick(this.onTry)
        }
        .height(62)
        .width('100%')
        .padding({ left: 22, right: 22 })
      }
      .width('90%')
      .height('96%')
      .backgroundColor(PANEL)
      .borderRadius(18)
      .shadow({ radius: 16, color: '#44000000', offsetX: 0, offsetY: 8 })
      .margin({ top: 14 })
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct RadioMark {
  selected: boolean = false;
  onTap: () => void = () => {};

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(28)
        .height(28)
        .fill(Color.Transparent)
        .stroke(this.selected ? BUTTON : '#6B6C76')
        .strokeWidth(2)
      if (this.selected) {
        Circle()
          .width(14)
          .height(14)
          .fill(BUTTON)
      }
    }
    .width(32)
    .height(32)
    .onClick(this.onTap)
  }
}

@Component
struct PurchaseOptionRow {
  label: string = '';
  onTap: () => void = () => {};

  build() {
    Row() {
      Text(this.label)
        .fontSize(17)
        .fontColor(TEXT)
        .width('100%')
    }
    .height(58)
    .width('100%')
    .padding({ left: 20, right: 20 })
    .alignItems(VerticalAlign.Center)
    .onClick(this.onTap)
  }
}

@Component
struct PremiumPurchaseOptionsPage {
  onClose: () => void = () => {};

  build() {
    Stack({ alignContent: Alignment.Center }) {
      FintsPremiumGatePage({ onClose: this.onClose, onTry: () => {}, initialPremiumOption: 'trial' })
      Column() {
        Blank()
          .height(342)
        Row() {
          Blank()
            .layoutWeight(1)
          Column() {
            PurchaseOptionRow({ label: SAMPLE_PRICE_6M, onTap: this.onClose })
            Divider().strokeWidth(1).color(LINE)
            PurchaseOptionRow({ label: SAMPLE_PRICE_12M, onTap: this.onClose })
            Divider().strokeWidth(1).color(LINE)
            PurchaseOptionRow({ label: SAMPLE_PRICE_24M, onTap: this.onClose })
          }
          .width(218)
          .backgroundColor(PANEL)
          .borderRadius(6)
          .shadow({ radius: 18, color: '#66000000', offsetX: 0, offsetY: 9 })
          Blank()
            .width(58)
        }
        .width('100%')
        Blank()
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
  }
}
