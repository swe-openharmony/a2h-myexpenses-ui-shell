import { MyExpensesShell } from '../components/MyExpensesShell';

@Entry
@Component
struct Index {
  build() {
    Stack() {
      MyExpensesShell()
    }
    .width('100%')
    .height('100%')
  }
}
