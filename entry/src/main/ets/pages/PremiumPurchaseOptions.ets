import { Phase2CapturePage, Phase2State } from '../components/MyExpensesShell';

@Entry
@Component
struct PremiumPurchaseOptions {
  build() {
    Stack() {
      Phase2CapturePage({ stateId: Phase2State.PremiumPurchaseOptions })
    }
    .width('100%')
    .height('100%')
  }
}
