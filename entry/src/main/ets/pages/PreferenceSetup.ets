import { Phase2CapturePage, Phase2State } from '../components/MyExpensesShell';

@Entry
@Component
struct PreferenceSetup {
  build() {
    Stack() {
      Phase2CapturePage({ stateId: Phase2State.PreferenceSetup })
    }
    .width('100%')
    .height('100%')
  }
}
