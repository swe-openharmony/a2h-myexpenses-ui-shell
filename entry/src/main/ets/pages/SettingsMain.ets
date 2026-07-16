import { Phase2CapturePage, Phase2State } from '../components/MyExpensesShell';

@Entry
@Component
struct SettingsMain {
  build() {
    Stack() {
      Phase2CapturePage({ stateId: Phase2State.Settings })
    }
    .width('100%')
    .height('100%')
  }
}
