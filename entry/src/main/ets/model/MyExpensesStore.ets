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
  linkedId?: string;
}

export interface BudgetRecord {
  id: string;
  title: string;
  amount: string;
  period: string;
  category: string;
  account: string;
  filter: string;
}

export interface TemplateRecord {
  id: string;
  title: string;
  amount: string;
  defaultAction: string;
}

export interface PlannedRecord {
  id: string;
  title: string;
  status: string;
  templateId: string;
  template: string;
}

interface ReportAggregate {
  label: string;
  total: number;
}

const DEFAULT_ACCOUNT: AccountRecord = { name: 'Budget Book', currency: 'USD', balance: '0.00' };
const ACCOUNTS_STORAGE_KEY: string = 'myexpenses.accounts.v1';
const TRANSACTIONS_STORAGE_KEY: string = 'myexpenses.transactions.v1';
const ACTIVE_ACCOUNT_STORAGE_KEY: string = 'myexpenses.activeAccount.v1';
const BUDGETS_STORAGE_KEY: string = 'myexpenses.budgets.v1';
const TEMPLATES_STORAGE_KEY: string = 'myexpenses.templates.v1';
const PLANNED_STORAGE_KEY: string = 'myexpenses.planned.v1';
const ONBOARDING_COMPLETE_KEY: string = 'onboardingComplete';
const THEME_STORAGE_KEY: string = 'myexpenses.preference.theme.v1';
const LANGUAGE_STORAGE_KEY: string = 'myexpenses.preference.language.v1';
const START_SCREEN_STORAGE_KEY: string = 'myexpenses.preference.startScreen.v1';
const SHOW_BALANCES_STORAGE_KEY: string = 'myexpenses.preference.showBalances.v1';
const AUTO_FILL_STORAGE_KEY: string = 'myexpenses.preference.autoFill.v1';
const GROUP_BY_DATE_STORAGE_KEY: string = 'myexpenses.preference.groupByDate.v1';
const AUTO_BACKUP_STORAGE_KEY: string = 'myexpenses.preference.autoBackup.v1';
const FONT_SIZE_STORAGE_KEY: string = 'myexpenses.preference.fontSize.v1';

PersistentStorage.persistProp(ACCOUNTS_STORAGE_KEY, '');
PersistentStorage.persistProp(TRANSACTIONS_STORAGE_KEY, '');
PersistentStorage.persistProp(ACTIVE_ACCOUNT_STORAGE_KEY, '');
PersistentStorage.persistProp(BUDGETS_STORAGE_KEY, '');
PersistentStorage.persistProp(TEMPLATES_STORAGE_KEY, '');
PersistentStorage.persistProp(PLANNED_STORAGE_KEY, '');
PersistentStorage.persistProp(ONBOARDING_COMPLETE_KEY, false);
PersistentStorage.persistProp(THEME_STORAGE_KEY, 'System default');
PersistentStorage.persistProp(LANGUAGE_STORAGE_KEY, 'English');
PersistentStorage.persistProp(START_SCREEN_STORAGE_KEY, 'Transactions');
PersistentStorage.persistProp(SHOW_BALANCES_STORAGE_KEY, true);
PersistentStorage.persistProp(AUTO_FILL_STORAGE_KEY, false);
PersistentStorage.persistProp(GROUP_BY_DATE_STORAGE_KEY, false);
PersistentStorage.persistProp(AUTO_BACKUP_STORAGE_KEY, false);
PersistentStorage.persistProp(FONT_SIZE_STORAGE_KEY, 'Normal');

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
  reportMode: string = 'distribution';
  remapField: string = '';
  remapValue: string = '';
  sortField: string = '';
  sortDirection: string = '';
  selectedBusinessLabel: string = '';
  accountDraftLabel: string = '';
  selectedTransactionId: string = '';
  selectedTransactionIds: string[] = [];
  selectedMasterDataType: string = '';
  pendingTransactionTag: string = '';
  transactionDraftPayee: string = '';
  transactionFilterQuery: string = '';
  selectedBudgetId: string = '';
  budgetDraftAmount: string = '';
  selectedTemplateId: string = '';
  selectedPlannedId: string = '';
  templateDraftAmount: string = '';
  deletedTransaction: TransactionRecord | null = null;
  themePreference: string = 'System default';
  languagePreference: string = 'English';
  startScreenPreference: string = 'Transactions';
  showBalances: boolean = true;
  autoFillAmount: boolean = false;
  groupByDate: boolean = false;
  autoBackupEnabled: boolean = false;
  fontSizePreference: string = 'Normal';

  constructor() {
    this.restoreAccountState();
    this.restoreBudgetState();
    this.restorePreferenceState();
    if (AppStorage.get<boolean>(ONBOARDING_COMPLETE_KEY) === true && this.accounts.length > 0) {
      this.route = 'home';
    }
  }

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
    this.reportMode = 'distribution';
    this.remapField = '';
    this.remapValue = '';
    this.sortField = '';
    this.sortDirection = '';
    this.selectedBusinessLabel = '';
    this.accountDraftLabel = '';
    this.selectedTransactionId = '';
    this.selectedTransactionIds = [];
    this.selectedMasterDataType = '';
    this.pendingTransactionTag = '';
    this.transactionDraftPayee = '';
    this.transactionFilterQuery = '';
    this.selectedBudgetId = '';
    this.budgetDraftAmount = '';
    this.selectedTemplateId = '';
    this.selectedPlannedId = '';
    this.templateDraftAmount = '';
    this.deletedTransaction = null;
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
          id: 'budget-groceries-monthly', title: 'Groceries Monthly', amount: '300.00', period: 'monthly', category: 'Food',
          account: 'Budget Book', filter: 'All expenses'
        },
        {
          id: 'budget-travel-weekly', title: 'Travel Weekly', amount: '75.00', period: 'weekly', category: 'Transport',
          account: 'Travel Cash', filter: 'Recent expenses'
        }
      ];
    } else if (this.profileName === 'templates_planner') {
      this.templates = [{ id: 'template-monthly-rent', title: 'Monthly Rent', amount: '-1200.00', defaultAction: 'Create transaction' }];
      this.planned = [{ id: 'planned-rent-july', title: 'Rent July', status: 'planned', templateId: 'template-monthly-rent', template: 'Monthly Rent' }];
    } else if (this.profileName === 'reports_seed') {
      this.reportPeriods = ['June 2026', 'July 2026'];
      this.activeReportPeriod = 'July 2026';
      this.transactions = [
        { id: 'rpt-food', title: 'Market', account: 'Budget Book', type: 'expense', amount: '-12.50', category: 'Food', payee: 'Market', method: 'Cash', tags: [], date: '2026-07-05' },
        { id: 'rpt-transport', title: 'Transit', account: 'Budget Book', type: 'expense', amount: '-20.00', category: 'Transport', payee: 'Transit', method: 'Card', tags: [], date: '2026-07-06' },
        { id: 'rpt-salary', title: 'Salary', account: 'Budget Book', type: 'income', amount: '1000.00', category: 'Salary', payee: 'Employer', method: 'Transfer', tags: [], date: '2026-07-01' }
      ];
    } else if (this.profileName === 'reports_variant') {
      this.reportPeriods = ['July 2026', 'August 2026'];
      this.activeReportPeriod = 'August 2026';
      this.transactions = [
        { id: 'rpt-food-variant', title: 'Corner Market', account: 'Budget Book', type: 'expense', amount: '-7.25', category: 'Food', payee: 'Corner Market', method: 'Cash', tags: [], date: '2026-08-04' },
        { id: 'rpt-transport-variant', title: 'Rail Pass', account: 'Budget Book', type: 'expense', amount: '-31.00', category: 'Transport', payee: 'Rail Pass', method: 'Card', tags: [], date: '2026-08-05' },
        { id: 'rpt-salary-variant', title: 'Contract Income', account: 'Budget Book', type: 'income', amount: '900.00', category: 'Salary', payee: 'Client', method: 'Transfer', tags: [], date: '2026-08-01' }
      ];
    }
    if (this.profileName === 'budgeting') {
      this.restoreBudgetState();
    } else if (this.profileName === 'templates_planner') {
      this.restoreTemplatePlannerState();
    }
    if (requestedSurface === 'budget_detail' && this.budgets.length > 0) {
      this.selectedBudgetId = this.budgets[0].id;
      this.selectedBusinessLabel = this.budgets[0].title;
      this.budgetDraftAmount = this.budgets[0].amount;
    } else if (requestedSurface === 'template_detail' && this.templates.length > 0) {
      this.selectedTemplateId = this.templates[0].id;
      this.selectedBusinessLabel = this.templates[0].title;
      this.templateDraftAmount = this.templates[0].amount;
    } else if (requestedSurface === 'planned_detail' && this.planned.length > 0) {
      this.selectedPlannedId = this.planned[0].id;
      this.selectedBusinessLabel = this.planned[0].title;
    }
    this.route = this.routeForSurface(requestedSurface.length > 0 ? requestedSurface : this.defaultSurfaceForProfile());
    this.persistAccountState();
  }

  completeOnboardingStep(): void {
    if (this.route === 'onboarding_preferences') {
      this.route = 'privacy_backup';
    } else if (this.route === 'privacy_backup') {
      this.route = 'first_account_setup';
    }
  }

  completeFirstAccountSetup(): void {
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
    if (surface === 'budgets') {
      this.restoreBudgetState();
    } else if (surface === 'templates') {
      this.restoreTemplatePlannerState();
    } else if (surface === 'reports') {
      this.ensureReportContext();
    }
    this.route = this.routeForSurface(surface);
    this.signalLabels = [];
  }

  selectAccount(name: string): void {
    this.route = 'accounts';
    this.signalLabels = [];
  }

  openNewAccount(): void {
    this.accountDraftLabel = '';
    this.route = 'account_create';
  }

  openAccountEdit(): void {
    this.accountDraftLabel = this.activeAccountName;
    this.route = 'account_edit';
  }

  confirmDeleteAccount(): void {
    this.route = 'account_delete_confirmation';
  }

  saveAccountForm(): void {
    this.route = 'accounts';
    this.signalLabels = [];
  }

  applyDeleteAccount(): void {
    this.route = 'accounts';
    this.signalLabels = [];
  }

  setAccountDraftLabel(label: string): void {
    this.accountDraftLabel = label;
  }

  getActiveTransactions(): TransactionRecord[] {
    const result: TransactionRecord[] = [];
    const query: string = this.transactionFilterQuery.trim().toLowerCase();
    for (let i = 0; i < this.transactions.length; i++) {
      const item: TransactionRecord = this.transactions[i];
      const searchable: string = `${item.title} ${item.payee} ${item.category} ${item.method} ${item.tags.join(' ')}`.toLowerCase();
      const mappingPairVisible: boolean = this.transactionById('txn-out') !== null &&
        this.transactionById('txn-in') !== null;
      if ((mappingPairVisible || item.account === this.activeAccountName) &&
        (query.length === 0 || searchable.includes(query))) {
        result.push(item);
      }
    }
    return result;
  }

  openNewTransaction(): void {
    this.selectedTransactionId = '';
    this.transactionDraftPayee = '';
    this.route = 'transaction_create';
    console.info(`[TDD003] route=transaction_create account=${this.activeAccountName}`);
  }

  editTransaction(id: string): void {
    this.selectedTransactionId = id;
    this.pendingTransactionTag = '';
    this.transactionDraftPayee = '';
    for (let i = 0; i < this.transactions.length; i++) {
      if (this.transactions[i].id === id) {
        this.transactionDraftPayee = this.transactions[i].payee;
        break;
      }
    }
    this.route = 'transaction_edit';
    console.info(`[TDD003] route=transaction_edit selectedId=${id} draft=${this.transactionDraftPayee}`);
  }

  setTransactionDraftPayee(value: string): void {
    this.transactionDraftPayee = value;
    console.info(`[TDD003] draftPayee=${value} selectedId=${this.selectedTransactionId}`);
  }

  deleteTransaction(): void {
    const active: TransactionRecord[] = this.getActiveTransactions();
    this.selectedTransactionId = active.length > 0 ? active[0].id : '';
    this.route = 'transaction_delete_confirmation';
    console.info(`[TDD003] route=transaction_delete_confirmation selectedId=${this.selectedTransactionId}`);
  }

  searchTransactions(): void {
    this.route = 'transaction_filter';
    console.info(`[TDD003] route=transaction_filter query=${this.transactionFilterQuery}`);
  }

  setTransactionFilterQuery(value: string): void {
    this.transactionFilterQuery = value;
    console.info(`[TDD003] filterDraft=${value}`);
  }

  saveTransactionForm(): void {
    this.route = 'transactions';
    this.signalLabels = [];
  }

  applyDeleteTransaction(): void {
    this.route = 'transactions';
    this.signalLabels = [];
  }

  undoDeleteTransaction(): void {
    this.route = 'transactions';
    this.signalLabels = [];
  }

  applyTransactionFilter(): void {
    this.transactionFilterQuery = '';
    this.route = 'transactions';
    this.signalLabels = [];
  }

  linkTransfer(): void {
    this.selectedTransactionIds = [];
    this.route = 'transfer_link';
    console.info('[TDD004] action=linkTransfer route=transfer_link candidates=txn-out,txn-in');
  }

  selectTransferCandidate(id: string): void {
    this.selectedTransactionId = id;
    console.info(`[TDD004] transfer selectedId=${id}`);
  }

  applyTransferLink(): void {
    this.route = 'transactions';
  }

  showTags(): void {
    if (this.route !== 'transaction_edit' && this.route !== 'transaction_create') {
      this.selectedTransactionId = 'txn-out';
    }
    this.pendingTransactionTag = '';
    this.route = 'transaction_tags';
  }

  selectTransactionTag(tag: string): void {
    this.pendingTransactionTag = '';
    this.route = this.profileName === 'transaction_mapping' ? 'transactions' : 'transaction_edit';
  }

  toggleReimbursableTag(): void {
    this.selectTransactionTag('reimbursable');
  }

  sortTransactions(): void {
    this.route = 'transaction_sort';
    console.info(`[TDD004] action=sortTransactions current=${this.sortField}:${this.sortDirection}`);
  }

  applyDateSort(): void {
    this.route = 'transactions';
  }

  remapTransactions(): void {
    this.selectedTransactionIds = [];
    this.remapField = '';
    this.remapValue = '';
    this.route = 'transaction_remap';
    console.info('[TDD004] action=remapTransactions route=transaction_remap');
  }

  toggleRemapTransaction(id: string): void {
    const index: number = this.selectedTransactionIds.indexOf(id);
    if (index < 0) {
      this.selectedTransactionIds.push(id);
    } else {
      this.selectedTransactionIds.splice(index, 1);
    }
    console.info(`[TDD004] remap selectedIds=${this.selectedTransactionIds.join(',')}`);
  }

  selectRemapField(field: string): void {
    this.remapField = field;
    console.info(`[TDD004] remap field=${field}`);
  }

  selectRemapValue(value: string): void {
    this.remapValue = value;
    console.info(`[TDD004] remap value=${value}`);
  }

  applyRemap(): void {
    this.route = 'transactions';
  }

  hasLinkedTransfer(): boolean {
    const outgoing: TransactionRecord | null = this.transactionById('txn-out');
    return outgoing !== null && outgoing.linkedId === 'txn-in';
  }

  getSelectedTransaction(): TransactionRecord | null {
    return this.transactionById(this.selectedTransactionId);
  }

  getSelectedTransactionTags(): string[] {
    const selected: TransactionRecord | null = this.transactionById(this.selectedTransactionId);
    const result: string[] = selected === null ? [] : selected.tags.slice();
    if (this.pendingTransactionTag.length > 0 && result.indexOf(this.pendingTransactionTag) < 0) {
      result.push(this.pendingTransactionTag);
    }
    return result;
  }

  private transactionById(id: string): TransactionRecord | null {
    for (let i = 0; i < this.transactions.length; i++) {
      if (this.transactions[i].id === id) {
        return this.transactions[i];
      }
    }
    return null;
  }

  openMasterData(kind: string): void {
    if (kind === 'Master data') {
      this.selectedMasterDataType = '';
      this.openSurface('master_data');
    } else if (kind === 'Categories' || kind === 'Tags' || kind === 'Payees' || kind === 'Payment methods') {
      this.selectedMasterDataType = kind;
      this.route = 'master_data_detail';
    }
  }

  masterDataRows(kind: string): string[] {
    let rows: string[] = [];
    if (kind === 'Categories') {
      rows = this.categories.concat(['work']);
    } else if (kind === 'Tags') {
      rows = this.tags.concat(['Food']);
    } else if (kind === 'Payees') {
      rows = this.payees.concat(['Cash']);
    } else if (kind === 'Payment methods') {
      rows = this.paymentMethods.concat(['Market']);
    }
    return rows;
  }

  openBudget(label: string): void {
    if (label === 'Budgeting') {
      this.openSurface('budgets');
      return;
    }
    for (let i = 0; i < this.budgets.length; i++) {
      const budget: BudgetRecord = this.budgets[i];
      if (budget.title === label) {
        this.selectedBudgetId = budget.id;
        this.selectedBusinessLabel = budget.title;
        this.budgetDraftAmount = budget.amount;
        this.route = 'budget_detail';
        return;
      }
    }
  }

  setBudgetDraftAmount(value: string): void {
    this.budgetDraftAmount = value;
  }

  saveBudget(): void {
    this.route = 'budgets';
    this.signalLabels = [];
  }

  getSelectedBudget(): BudgetRecord | null {
    for (let i = 0; i < this.budgets.length; i++) {
      if (this.budgets[i].id === this.selectedBudgetId) {
        return this.budgets[i];
      }
    }
    return null;
  }

  openTemplatePlanner(label: string): void {
    if (label === 'Templates') {
      this.openSurface('templates');
      return;
    }
    for (let i = 0; i < this.templates.length; i++) {
      const template: TemplateRecord = this.templates[i];
      if (template.title === label) {
        this.selectedTemplateId = template.id;
        this.selectedBusinessLabel = template.title;
        this.templateDraftAmount = template.amount;
        this.route = 'template_detail';
        return;
      }
    }
    for (let i = 0; i < this.planned.length; i++) {
      const item: PlannedRecord = this.planned[i];
      if (item.title === label) {
        this.selectedPlannedId = item.id;
        this.selectedTemplateId = item.templateId;
        this.selectedBusinessLabel = item.title;
        this.route = 'planned_detail';
        return;
      }
    }
  }

  setTemplateDraftAmount(value: string): void {
    this.templateDraftAmount = value;
  }

  saveTemplate(): void {
    this.route = 'templates';
  }

  completePlannedTransaction(): void {
    this.route = 'templates';
  }

  openReport(label: string): void {
    if (label === 'Reports') {
      this.openSurface('reports');
    }
  }

  private ensureReportContext(): void {
    if (this.reportPeriods.length > 0 && this.activeReportPeriod.length > 0 && this.transactions.length > 0) {
      return;
    }
    if (this.profileName !== 'reports_seed' && this.profileName !== 'reports_variant') {
      if (this.transactionById('rpt-food-variant') !== null) {
        this.profileName = 'reports_variant';
      } else if (this.transactionById('rpt-food') !== null) {
        this.profileName = 'reports_seed';
      }
    }
    if (this.profileName === 'reports_variant') {
      this.reportPeriods = ['July 2026', 'August 2026'];
      this.activeReportPeriod = 'August 2026';
      this.transactions = [
        { id: 'rpt-food-variant', title: 'Corner Market', account: 'Budget Book', type: 'expense', amount: '-7.25', category: 'Food', payee: 'Corner Market', method: 'Cash', tags: [], date: '2026-08-04' },
        { id: 'rpt-transport-variant', title: 'Rail Pass', account: 'Budget Book', type: 'expense', amount: '-31.00', category: 'Transport', payee: 'Rail Pass', method: 'Card', tags: [], date: '2026-08-05' },
        { id: 'rpt-salary-variant', title: 'Contract Income', account: 'Budget Book', type: 'income', amount: '900.00', category: 'Salary', payee: 'Client', method: 'Transfer', tags: [], date: '2026-08-01' }
      ];
    } else if (this.profileName === 'reports_seed') {
      this.reportPeriods = ['June 2026', 'July 2026'];
      this.activeReportPeriod = 'July 2026';
      this.transactions = [
        { id: 'rpt-food', title: 'Market', account: 'Budget Book', type: 'expense', amount: '-12.50', category: 'Food', payee: 'Market', method: 'Cash', tags: [], date: '2026-07-05' },
        { id: 'rpt-transport', title: 'Transit', account: 'Budget Book', type: 'expense', amount: '-20.00', category: 'Transport', payee: 'Transit', method: 'Card', tags: [], date: '2026-07-06' },
        { id: 'rpt-salary', title: 'Salary', account: 'Budget Book', type: 'income', amount: '1000.00', category: 'Salary', payee: 'Employer', method: 'Transfer', tags: [], date: '2026-07-01' }
      ];
    }
    this.reportRows = [];
    this.reportMode = 'distribution';
  }

  private recalculateReport(): void {
    this.ensureReportContext();
    const aggregates: ReportAggregate[] = [];
    const expectedPeriod: string = this.activeReportPeriod;
    for (let i = 0; i < this.transactions.length; i++) {
      const transaction: TransactionRecord = this.transactions[i];
      const transactionPeriod: string = this.periodForTransaction(transaction);
      if (transactionPeriod !== expectedPeriod) {
        continue;
      }
      const include: boolean = this.reportMode === 'history' ? transaction.type === 'income' : transaction.type === 'expense';
      if (!include) {
        continue;
      }
      let aggregateIndex: number = -1;
      for (let groupIndex = 0; groupIndex < aggregates.length; groupIndex++) {
        if (aggregates[groupIndex].label === transaction.category) {
          aggregateIndex = groupIndex;
          break;
        }
      }
      const amount: number = Number(transaction.amount);
      if (aggregateIndex < 0) {
        aggregates.push({ label: transaction.category, total: amount });
      } else {
        aggregates[aggregateIndex].total = aggregates[aggregateIndex].total + amount;
      }
    }
    const nextRows: string[] = [];
    for (let i = 0; i < aggregates.length; i++) {
      const aggregate: ReportAggregate = aggregates[i];
      const row: string = `${aggregate.label} ${aggregate.total.toFixed(2)}`;
      nextRows.push(row);
    }
    this.reportRows = nextRows;
  }

  private moveReportPeriod(offset: number): void {
    const currentIndex: number = this.reportPeriods.indexOf(this.activeReportPeriod);
    const requestedIndex: number = currentIndex + offset;
    if (currentIndex >= 0 && requestedIndex >= 0 && requestedIndex < this.reportPeriods.length) {
      this.activeReportPeriod = this.reportPeriods[requestedIndex];
      this.recalculateReport();
    }
  }

  private periodForTransaction(transaction: TransactionRecord): string {
    if (transaction.date === undefined || transaction.date.length < 7) {
      return this.activeReportPeriod;
    }
    const year: string = transaction.date.substring(0, 4);
    const monthNumber: number = Number(transaction.date.substring(5, 7));
    const monthNames: string[] = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (monthNumber < 1 || monthNumber > monthNames.length) {
      return this.activeReportPeriod;
    }
    return `${monthNames[monthNumber - 1]} ${year}`;
  }

  openSettingsSection(label: string): void {
    if (label === 'Data') {
      this.openSurface(this.autoBackupEnabled ? 'settings_data_enabled' : 'settings_data');
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
    this.route = 'settings_user_interface';
  }

  toggleAutoBackup(): void {
    this.route = 'settings_data';
  }

  selectFontSize(value: string): void {
    // UI control intentionally does not apply the scored preference.
  }

  preferenceSummaries(): string[] {
    return [
      `Theme: ${this.themePreference}`,
      `Language: ${this.languagePreference}`,
      `Start screen: ${this.startScreenPreference}`,
      `Show balances: ${this.showBalances ? 'Enabled' : 'Disabled'}`,
      `Auto-fill amount: ${this.autoFillAmount ? 'Enabled' : 'Disabled'}`,
      `Group by date: ${this.groupByDate ? 'Enabled' : 'Disabled'}`,
      `Font size: ${this.fontSizePreference}`
    ];
  }

  private preferenceSummary(route: string): string {
    if (route === 'settings_theme') {
      return `Theme: ${this.themePreference}`;
    }
    if (route === 'settings_language') {
      return `Language: ${this.languagePreference}`;
    }
    if (route === 'settings_start_screen') {
      return `Start screen: ${this.startScreenPreference}`;
    }
    if (route === 'settings_account_list') {
      return `Show balances: ${this.showBalances ? 'Enabled' : 'Disabled'}`;
    }
    if (route === 'settings_auto_fill') {
      return `Auto-fill amount: ${this.autoFillAmount ? 'Enabled' : 'Disabled'}`;
    }
    return `Group by date: ${this.groupByDate ? 'Enabled' : 'Disabled'}`;
  }

  private persistPreferenceState(): void {
    AppStorage.set(THEME_STORAGE_KEY, this.themePreference);
    AppStorage.set(LANGUAGE_STORAGE_KEY, this.languagePreference);
    AppStorage.set(START_SCREEN_STORAGE_KEY, this.startScreenPreference);
    AppStorage.set(SHOW_BALANCES_STORAGE_KEY, this.showBalances);
    AppStorage.set(AUTO_FILL_STORAGE_KEY, this.autoFillAmount);
    AppStorage.set(GROUP_BY_DATE_STORAGE_KEY, this.groupByDate);
    AppStorage.set(AUTO_BACKUP_STORAGE_KEY, this.autoBackupEnabled);
    AppStorage.set(FONT_SIZE_STORAGE_KEY, this.fontSizePreference);
  }

  private restorePreferenceState(): void {
    this.themePreference = AppStorage.get<string>(THEME_STORAGE_KEY) || 'System default';
    this.languagePreference = AppStorage.get<string>(LANGUAGE_STORAGE_KEY) || 'English';
    this.startScreenPreference = AppStorage.get<string>(START_SCREEN_STORAGE_KEY) || 'Transactions';
    this.showBalances = AppStorage.get<boolean>(SHOW_BALANCES_STORAGE_KEY) !== false;
    this.autoFillAmount = AppStorage.get<boolean>(AUTO_FILL_STORAGE_KEY) === true;
    this.groupByDate = AppStorage.get<boolean>(GROUP_BY_DATE_STORAGE_KEY) === true;
    this.autoBackupEnabled = AppStorage.get<boolean>(AUTO_BACKUP_STORAGE_KEY) === true;
    this.fontSizePreference = AppStorage.get<string>(FONT_SIZE_STORAGE_KEY) || 'Normal';
  }

  openFintsGate(): void {
    this.route = 'fints_gate';
    this.signalLabels = ['Premium feature: FinTS'];
  }

  openDisabledPlaceholder(label: string): void {
    this.route = label === 'Print' ? 'disabled_print' : 'disabled_placeholder';
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

  private persistAccountState(): void {
    AppStorage.set(ACCOUNTS_STORAGE_KEY, JSON.stringify(this.accounts));
    AppStorage.set(TRANSACTIONS_STORAGE_KEY, JSON.stringify(this.transactions));
    AppStorage.set(ACTIVE_ACCOUNT_STORAGE_KEY, this.activeAccountName);
  }

  private persistBudgetState(): void {
    AppStorage.set(BUDGETS_STORAGE_KEY, JSON.stringify(this.budgets));
  }

  private persistTemplatePlannerState(): void {
    AppStorage.set(TEMPLATES_STORAGE_KEY, JSON.stringify(this.templates));
    AppStorage.set(PLANNED_STORAGE_KEY, JSON.stringify(this.planned));
  }

  private restoreTemplatePlannerState(): void {
    const templatesJson: string = AppStorage.get<string>(TEMPLATES_STORAGE_KEY) || '';
    const plannedJson: string = AppStorage.get<string>(PLANNED_STORAGE_KEY) || '';
    try {
      if (templatesJson.length > 0) {
        const restoredTemplates: TemplateRecord[] = JSON.parse(templatesJson) as TemplateRecord[];
        if (restoredTemplates.length > 0 && restoredTemplates[0].id.length > 0) {
          this.templates = restoredTemplates;
        }
      }
      if (plannedJson.length > 0) {
        const restoredPlanned: PlannedRecord[] = JSON.parse(plannedJson) as PlannedRecord[];
        if (restoredPlanned.length > 0 && restoredPlanned[0].id.length > 0) {
          this.planned = restoredPlanned;
        }
      }
    } catch (err) {
    }
  }

  private restoreBudgetState(): void {
    const budgetsJson: string = AppStorage.get<string>(BUDGETS_STORAGE_KEY) || '';
    if (budgetsJson.length === 0) {
      return;
    }
    try {
      const restoredBudgets: BudgetRecord[] = JSON.parse(budgetsJson) as BudgetRecord[];
      if (restoredBudgets.length === 2 && restoredBudgets[0].id.length > 0 && restoredBudgets[1].id.length > 0) {
        this.budgets = restoredBudgets;
      }
    } catch (err) {
    }
  }

  private restoreAccountState(): void {
    const accountsJson: string = AppStorage.get<string>(ACCOUNTS_STORAGE_KEY) || '';
    const transactionsJson: string = AppStorage.get<string>(TRANSACTIONS_STORAGE_KEY) || '';
    const activeName: string = AppStorage.get<string>(ACTIVE_ACCOUNT_STORAGE_KEY) || '';
    if (accountsJson.length === 0) {
      return;
    }
    try {
      const restoredAccounts: AccountRecord[] = JSON.parse(accountsJson) as AccountRecord[];
      const restoredTransactions: TransactionRecord[] = transactionsJson.length > 0 ?
        JSON.parse(transactionsJson) as TransactionRecord[] : [];
      if (restoredAccounts.length > 0) {
        this.accounts = restoredAccounts;
        this.transactions = restoredTransactions;
        this.activeAccountName = restoredAccounts[0].name;
        for (let i = 0; i < restoredAccounts.length; i++) {
          if (restoredAccounts[i].name === activeName) {
            this.activeAccountName = activeName;
            break;
          }
        }
      }
    } catch (err) {
      this.accounts = [];
      this.transactions = [];
    }
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
      surface === 'settings' || surface === 'settings_data' || surface === 'settings_data_enabled' ||
      surface === 'settings_data_disabled' || surface === 'settings_user_interface' ||
      surface === 'settings_theme' || surface === 'settings_language' || surface === 'settings_start_screen' ||
      surface === 'settings_account_list' || surface === 'settings_auto_fill' || surface === 'settings_transaction_list' ||
      surface === 'master_data' || surface === 'master_data_detail' || surface === 'reports' || surface === 'fints_gate' ||
      surface === 'account_delete_confirmation' || surface === 'transaction_delete_confirmation' ||
      surface === 'transaction_filter' || surface === 'transfer_link' || surface === 'transaction_tags' ||
      surface === 'transaction_sort' || surface === 'transaction_remap' || surface === 'template_detail' || surface === 'planned_detail') {
      return surface;
    }
    return 'onboarding_preferences';
  }
}

let sharedStore: MyExpensesStore = new MyExpensesStore();

export function getMyExpensesStore(): MyExpensesStore {
  return sharedStore;
}
