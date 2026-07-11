import { Phase2CapturePage, Phase2State } from '../components/MyExpensesShell';

@Entry
@Component
struct PrivacyBackup {
  build() {
    Stack() {
      Phase2CapturePage({ stateId: Phase2State.PrivacyBackup })
    }
    .width('100%')
    .height('100%')
  }
}
