import { Phase2CapturePage, Phase2State } from '../components/MyExpensesShell';

@Entry
@Component
struct EmptyHome {
  build() {
    Stack() {
      Phase2CapturePage({ stateId: Phase2State.EmptyHome })
    }
    .width('100%')
    .height('100%')
  }
}
