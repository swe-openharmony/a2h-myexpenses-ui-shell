export interface AccountRecord {
  name: string;
  currency: string;
  balance: string;
}

export interface CategoryRecord {
  name: string;
  parent: string;
  type: string;
  isDefault: boolean;
}

export interface TransactionRecord {
  id: string;
  title: string;
  account: string;
  type: string;
  amount: string;
  category: string;
  payee: string;
  method: string;
  tags: string[];
  date?: string;
}

export interface BudgetRecord {
  title: string;
  amount: string;
  period: string;
  category: string;
  account: string;
  filter: string;
}

export interface TemplateRecord {
  title: string;
  amount: string;
  defaultAction: string;
}

export interface PlannedRecord {
  title: string;
  status: string;
  template: string;
}

const DEFAULT_ACCOUNT: AccountRecord = { name: 'Budget Book', currency: 'USD', balance: '0.00' };

export class MyExpensesStore {
  route: string = 'onboarding_preferences';
  profileName: string = 'onboarding_preferences';
  activeAccountName: string = 'Budget Book';
  signalLabels: string[] = [];
  accounts: AccountRecord[] = [];
  transactions: TransactionRecord[] = [];
  categories: string[] = [];
  categoryRecords: CategoryRecord[] = [];
  tags: string[] = [];
  payees: string[] = [];
  paymentMethods: string[] = [];
  budgets: BudgetRecord[] = [];
  templates: TemplateRecord[] = [];
  planned: PlannedRecord[] = [];
  reportRows: string[] = [];
  currencies: string[] = [];
  themeOptions: string[] = [];
  advancedAccountFields: string[] = [];
  restoreUnavailableSummary: string = '';
  reportPeriods: string[] = [];
  activeReportPeriod: string = '';
  remapField: string = '';
  remapValue: string = '';
  sortField: string = '';
  sortDirection: string = '';
  selectedBusinessLabel: string = '';

  resetToProfile(name: string, requestedSurface: string = ''): void {
    this.profileName = this.normalizeProfile(name);
    this.signalLabels = [];
    this.accounts = [DEFAULT_ACCOUNT];
    this.activeAccountName = 'Budget Book';
    this.transactions = [];
    this.categories = [];
    this.categoryRecords = [];
    this.tags = [];
    this.payees = [];
    this.paymentMethods = [];
    this.budgets = [];
    this.templates = [];
    this.planned = [];
    this.reportRows = [];
    this.currencies = [];
    this.themeOptions = [];
    this.advancedAccountFields = [];
    this.restoreUnavailableSummary = '';
    this.reportPeriods = [];
    this.activeReportPeriod = '';
    this.remapField = '';
    this.remapValue = '';
    this.sortField = '';
    this.sortDirection = '';
    this.selectedBusinessLabel = '';
    if (this.profileName === 'onboarding_preferences') {
      this.accounts = [];
      this.themeOptions = ['System default', 'Light', 'Dark'];
    } else if (this.profileName === 'privacy_setup') {
      this.accounts = [];
    } else if (this.profileName === 'first_account_setup') {
      this.accounts = [];
      this.currencies = ['US Dollar', 'Euro'];
      this.advancedAccountFields = ['Account type', 'Group', 'Exclude from totals'];
      this.restoreUnavailableSummary = 'Restore unavailable on this device';
    } else if (this.profileName === 'two_accounts_with_transactions') {
      this.accounts = [
        { name: 'Budget Book', currency: 'USD', balance: '0.00' },
        { name: 'Travel Cash', currency: 'USD', balance: '100.00' }
      ];
      this.transactions = [{
        id: 'txn-food', title: 'Market', account: 'Budget Book', type: 'expense', amount: '-12.50', category: 'Food', payee: 'Market',
        method: 'Cash', tags: ['groceries']
      }];
    } else if (this.profileName === 'transaction_crud') {
      this.categories = ['Food', 'Salary'];
      this.payees = ['Market'];
      this.paymentMethods = ['Cash'];
      this.tags = ['groceries', 'work'];
      this.transactions = [{
        id: 'txn-food', title: 'Market', account: 'Budget Book', type: 'expense', amount: '-12.50', category: 'Food', payee: 'Market',
        method: 'Cash', tags: ['groceries']
      }];
    } else if (this.profileName === 'transaction_mapping') {
      this.accounts = [
        { name: 'Budget Book', currency: 'USD', balance: '0.00' },
        { name: 'Travel Cash', currency: 'USD', balance: '100.00' }
      ];
      this.tags = ['reimbursable'];
      this.transactions = [
        {
          id: 'txn-out', title: 'Outgoing transfer candidate', account: 'Budget Book', type: 'expense', amount: '-25.00', category: 'Transfer',
          payee: 'Travel Cash', method: '', tags: [], date: '2026-07-02'
        },
        {
          id: 'txn-in', title: 'Incoming transfer candidate', account: 'Travel Cash', type: 'income', amount: '25.00', category: 'Transfer',
          payee: 'Budget Book', method: '', tags: [], date: '2026-07-01'
        }
      ];
    } else if (this.profileName === 'master_data_crud') {
      this.categories = ['Food', 'Groceries', 'Transport'];
      this.categoryRecords = [
        { name: 'Food', parent: '', type: 'expense', isDefault: true },
        { name: 'Groceries', parent: 'Food', type: 'expense', isDefault: false },
        { name: 'Transport', parent: '', type: 'expense', isDefault: false }
      ];
      this.tags = ['work'];
      this.payees = ['Market'];
      this.paymentMethods = ['Cash'];
    } else if (this.profileName === 'budgeting') {
      this.accounts = [
        { name: 'Budget Book', currency: 'USD', balance: '0.00' },
        { name: 'Travel Cash', currency: 'USD', balance: '100.00' }
      ];
      this.budgets = [
        {
          title: 'Groceries Monthly', amount: '300.00', period: 'monthly', category: 'Food',
          account: 'Budget Book', filter: 'All expenses'
        },
        {
          title: 'Travel Weekly', amount: '75.00', period: 'weekly', category: 'Transport',
          account: 'Travel Cash', filter: 'Recent expenses'
        }
      ];
    } else if (this.profileName === 'templates_planner') {
      this.templates = [{ title: 'Monthly Rent', amount: '-1200.00', defaultAction: 'Create transaction' }];
      this.planned = [{ title: 'Rent July', status: 'planned', template: 'Monthly Rent' }];
    } else if (this.profileName === 'reports_seed') {
      this.reportPeriods = ['June 2026', 'July 2026'];
      this.activeReportPeriod = 'July 2026';
      this.transactions = [
        { id: 'rpt-food', title: 'Market', account: 'Budget Book', type: 'expense', amount: '-12.50', category: 'Food', payee: 'Market', method: 'Cash', tags: [] },
        { id: 'rpt-transport', title: 'Transit', account: 'Budget Book', type: 'expense', amount: '-20.00', category: 'Transport', payee: 'Transit', method: 'Card', tags: [] },
        { id: 'rpt-salary', title: 'Salary', account: 'Budget Book', type: 'income', amount: '1000.00', category: 'Salary', payee: 'Employer', method: 'Transfer', tags: [] }
      ];
    } else if (this.profileName === 'reports_variant') {
      this.reportPeriods = ['July 2026', 'August 2026'];
      this.activeReportPeriod = 'August 2026';
      this.transactions = [
        { id: 'rpt-food-variant', title: 'Corner Market', account: 'Budget Book', type: 'expense', amount: '-7.25', category: 'Food', payee: 'Corner Market', method: 'Cash', tags: [] },
        { id: 'rpt-transport-variant', title: 'Rail Pass', account: 'Budget Book', type: 'expense', amount: '-31.00', category: 'Transport', payee: 'Rail Pass', method: 'Card', tags: [] },
        { id: 'rpt-salary-variant', title: 'Contract Income', account: 'Budget Book', type: 'income', amount: '900.00', category: 'Salary', payee: 'Client', method: 'Transfer', tags: [] }
      ];
    }
    if (requestedSurface === 'budget_detail' && this.budgets.length > 0) {
      this.selectedBusinessLabel = this.budgets[0].title;
    } else if (requestedSurface === 'template_detail' && this.templates.length > 0) {
      this.selectedBusinessLabel = this.templates[0].title;
    } else if (requestedSurface === 'planned_detail' && this.planned.length > 0) {
      this.selectedBusinessLabel = this.planned[0].title;
    }
    this.route = this.routeForSurface(requestedSurface.length > 0 ? requestedSurface : this.defaultSurfaceForProfile());
  }

  completeOnboardingStep(): void {
    if (this.route === 'onboarding_preferences') {
      this.route = 'privacy_backup';
    } else if (this.route === 'privacy_backup') {
      this.route = 'first_account_setup';
    }
  }

  completeFirstAccountSetup(): void {
    if (this.accounts.length === 0) {
      this.accounts = [DEFAULT_ACCOUNT];
    }
    this.activeAccountName = 'Budget Book';
    this.route = 'home';
    this.signalLabels = [];
  }

  openMoreSheet(): void {
    this.route = 'more_sheet';
    this.signalLabels = [];
  }

  closeSheet(): void {
    this.route = 'home';
  }

  openSettings(): void {
    this.route = 'settings';
    this.signalLabels = [];
  }

  openHome(): void {
    this.route = 'home';
    this.signalLabels = [];
  }

  openSurface(surface: string): void {
    this.route = this.routeForSurface(surface);
    this.signalLabels = [];
  }

  selectAccount(name: string): void {
  }

  openNewAccount(): void {
    this.route = 'account_create';
  }

  openAccountEdit(): void {
    this.route = 'account_edit';
  }

  confirmDeleteAccount(): void {
    this.route = 'account_delete_confirmation';
  }

  saveAccountForm(): void {
  }

  applyDeleteAccount(): void {
  }

  openNewTransaction(): void {
    this.route = 'transaction_create';
  }

  editTransaction(): void {
    this.route = 'transaction_edit';
  }

  deleteTransaction(): void {
    this.route = 'transaction_delete_confirmation';
  }

  searchTransactions(): void {
    this.route = 'transaction_filter';
  }

  saveTransactionForm(): void {
  }

  applyDeleteTransaction(): void {
  }

  undoDeleteTransaction(): void {
  }

  applyTransactionFilter(): void {
  }

  linkTransfer(): void {
  }

  showTags(): void {
  }

  sortTransactions(): void {
  }

  remapTransactions(): void {
  }

  openMasterData(kind: string): void {
    if (kind === 'Master data') {
      this.openSurface('master_data');
    }
  }

  openBudget(label: string): void {
    if (label === 'Budgeting') {
      this.openSurface('budgets');
    } else {
      this.selectedBusinessLabel = label;
      this.route = 'budget_detail';
    }
  }

  saveBudget(): void {
  }

  openTemplatePlanner(label: string): void {
    if (label === 'Templates') {
      this.openSurface('templates');
    } else if (label === 'Monthly Rent') {
      this.selectedBusinessLabel = label;
      this.route = 'template_detail';
    } else if (label === 'Rent July') {
      this.selectedBusinessLabel = label;
      this.route = 'planned_detail';
    }
  }

  saveTemplate(): void {
  }

  completePlannedTransaction(): void {
  }

  openReport(label: string): void {
    if (label === 'Reports') {
      this.openSurface('reports');
    }
  }

  openSettingsSection(label: string): void {
    if (label === 'Data') {
      this.openSurface('settings_data');
    } else if (label === 'User interface') {
      this.openSurface('settings_user_interface');
    }
  }

  openPreference(label: string): void {
    if (label === 'Theme') {
      this.route = 'settings_theme';
    } else if (label === 'Language') {
      this.route = 'settings_language';
    } else if (label === 'Start screen') {
      this.route = 'settings_start_screen';
    } else if (label === 'Account list') {
      this.route = 'settings_account_list';
    } else if (label === 'Auto-fill') {
      this.route = 'settings_auto_fill';
    } else if (label === 'Transaction list') {
      this.route = 'settings_transaction_list';
    }
  }

  selectPreference(value: string): void {
  }

  openFintsGate(): void {
    this.route = 'fints_gate';
    this.signalLabels = ['Premium feature: FinTS'];
  }

  openDisabledPlaceholder(label: string): void {
    this.route = 'settings';
    this.signalLabels = [`${label} unavailable on this device`, 'Disabled'];
  }

  getActiveBalance(): string {
    for (let i = 0; i < this.accounts.length; i++) {
      if (this.accounts[i].name === this.activeAccountName) {
        return this.accounts[i].balance;
      }
    }
    return '0.00';
  }

  private normalizeProfile(name: string): string {
    if (name.length === 0) {
      return 'onboarding_preferences';
    }
    return name;
  }

  private defaultSurfaceForProfile(): string {
    if (this.profileName === 'onboarding_preferences' || this.profileName === 'privacy_setup' ||
      this.profileName === 'first_account_setup') {
      return this.profileName;
    }
    if (this.profileName === 'settings_defaults') {
      return 'settings';
    }
    if (this.profileName === 'more_sheet' || this.profileName === 'fints_gate') {
      return this.profileName;
    }
    if (this.profileName === 'transaction_crud' || this.profileName === 'transaction_mapping') {
      return 'transactions';
    }
    if (this.profileName === 'master_data_crud') {
      return 'master_data';
    }
    if (this.profileName === 'budgeting') {
      return 'budgets';
    }
    if (this.profileName === 'templates_planner') {
      return 'templates';
    }
    if (this.profileName === 'reports_seed' || this.profileName === 'reports_variant') {
      return 'reports';
    }
    return 'home';
  }

  private routeForSurface(surface: string): string {
    if (surface === 'privacy_setup') {
      return 'privacy_backup';
    }
    if (surface === 'budgets') {
      return 'budgets';
    }
    if (surface === 'budget_detail') {
      return 'budget_detail';
    }
    if (surface === 'account_form') {
      return 'account_create';
    }
    if (surface === 'transaction_form') {
      return 'transaction_create';
    }
    if (surface === 'onboarding_preferences' || surface === 'first_account_setup' || surface === 'home' ||
      surface === 'accounts' || surface === 'transactions' || surface === 'templates' || surface === 'more_sheet' ||
      surface === 'settings' || surface === 'settings_data' || surface === 'settings_user_interface' ||
      surface === 'settings_theme' || surface === 'settings_language' || surface === 'settings_start_screen' ||
      surface === 'settings_account_list' || surface === 'settings_auto_fill' || surface === 'settings_transaction_list' ||
      surface === 'master_data' || surface === 'reports' || surface === 'fints_gate' ||
      surface === 'account_delete_confirmation' || surface === 'transaction_delete_confirmation' ||
      surface === 'transaction_filter' || surface === 'template_detail' || surface === 'planned_detail') {
      return surface;
    }
    return 'onboarding_preferences';
  }
}

let sharedStore: MyExpensesStore = new MyExpensesStore();

export function getMyExpensesStore(): MyExpensesStore {
  return sharedStore;
}
