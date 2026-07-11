import { Phase2CapturePage, Phase2State } from '../components/MyExpensesShell';

@Entry
@Component
struct FirstAccountSetup {
  build() {
    Stack() {
      Phase2CapturePage({ stateId: Phase2State.FirstAccountSetup })
    }
    .width('100%')
    .height('100%')
  }
}
