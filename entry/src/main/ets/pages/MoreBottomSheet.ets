import { Phase2CapturePage, Phase2State } from '../components/MyExpensesShell';

@Entry
@Component
struct MoreBottomSheet {
  build() {
    Stack() {
      Phase2CapturePage({ stateId: Phase2State.MoreBottomSheet })
    }
    .width('100%')
    .height('100%')
  }
}
