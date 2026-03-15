// Check code generation of cilk_spawn in conditional expressions.
//
// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -fopencilk -ftapir=none -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

int get_value(void) { return 42; }

int test_conditional_expression(int some_condition) {
    // Test conditional expression in binary assignment
    int value1, value3;
    value1 = some_condition ? cilk_spawn get_value() : 1;
    // Test conditional expression in variable initialization
    int value2 = !some_condition ? cilk_spawn get_value() : 2;
    // Test conditional expressions with spawns in false branch
    value3 = some_condition ? 1: cilk_spawn get_value();
    // Test conditional expression in variable initialization
    int value4 = !some_condition ? 2: cilk_spawn get_value();
    cilk_sync;
    return value1 + value2 - value3 - value4;
}

// CHECK-LABEL: define {{.*}}i32 @test_conditional_expression(
// CHECK: %[[SOME_CONDITION_ADDR:.+]] = alloca i32
// CHECK: %[[VALUE1:.+]] = alloca i32
// CHECK: %[[VALUE3:.+]] = alloca i32
// CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
// CHECK: %[[VALUE2:.+]] = alloca i32
// CHECK: %[[VALUE4:.+]] = alloca i32
// CHECK: br i1 %[[TOBOOL:.+]], label %[[COND_TRUE:.+]], label %[[COND_FALSE:.+]]

// CHECK: [[COND_TRUE]]:
// CHECK-NEXT: %[[TF1:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]]

// CHECK: [[DETACHED]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF1]])
// CHECK-NEXT: %[[CALL:.+]] = call {{.*}}i32 @get_value()
// CHECK-NEXT: store i32 %[[CALL]], ptr %[[VALUE1]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK-NEXT: br label %[[COND_END:.+]]

// CHECK: [[COND_FALSE]]:
// CHECK-NEXT: store i32 1, ptr %[[VALUE1]]
// CHECK-NEXT: br label %[[COND_END]]

// CHECK: [[COND_END]]:
// CHECK-NOT: phi
// CHECK-NOT: store
// CHECK: br i1 %[[TOBOOL1:.+]], label %[[COND_FALSE6:.+]], label %[[COND_TRUE2:.+]]

// CHECK: [[COND_TRUE2]]:
// CHECK-NEXT: %[[TF3:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED3:.+]], label %[[CONTINUE5:.+]]

// CHECK: [[DETACHED3]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF3]])
// CHECK-NEXT: %[[CALL4:.+]] = call {{.*}}i32 @get_value()
// CHECK-NEXT: store i32 %[[CALL4]], ptr %[[VALUE2]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE5]]

// CHECK: [[CONTINUE5]]:
// CHECK-NEXT: br label %[[COND_END7:.+]]

// CHECK: [[COND_FALSE6]]:
// CHECK-NEXT: store i32 2, ptr %[[VALUE2]]
// CHECK-NEXT: br label %[[COND_END7]]

// CHECK: [[COND_END7]]:
// CHECK-NOT: phi
// CHECK-NOT: store
// CHECK: br i1 %[[TOBOOL8:.+]], label %[[COND_TRUE9:.+]], label %[[COND_FALSE10:.+]]

// CHECK: [[COND_TRUE9]]:
// CHECK-NEXT: store i32 1, ptr %[[VALUE3]]
// CHECK-NEXT: br label %[[COND_END14:.+]]

// CHECK: [[COND_FALSE10]]:
// CHECK-NEXT: %[[TF5:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED11:.+]], label %[[CONTINUE13:.+]]

// CHECK: [[DETACHED11]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF5]])
// CHECK-NEXT: %[[CALL12:.+]] = call {{.*}}i32 @get_value()
// CHECK-NEXT: store i32 %[[CALL12]], ptr %[[VALUE3]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE13]]

// CHECK: [[CONTINUE13]]:
// CHECK-NEXT: br label %[[COND_END14]]

// CHECK: [[COND_END14]]:
// CHECK-NOT: phi
// CHECK-NOT: store
// CHECK: br i1 %[[TOBOOL15:.+]], label %[[COND_FALSE17:.+]], label %[[COND_TRUE16:.+]]

// CHECK: [[COND_TRUE16]]:
// CHECK-NEXT: store i32 2, ptr %[[VALUE4]]
// CHECK-NEXT: br label %[[COND_END21:.+]]

// CHECK: [[COND_FALSE17]]:
// CHECK-NEXT: %[[TF7:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED18:.+]], label %[[CONTINUE20:.+]]

// CHECK: [[DETACHED18]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF7]])
// CHECK-NEXT: %[[CALL19:.+]] = call {{.*}}i32 @get_value()
// CHECK-NEXT: store i32 %[[CALL19]], ptr %[[VALUE4]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE20]]

// CHECK: [[CONTINUE20]]:
// CHECK-NEXT: br label %[[COND_END21]]

// CHECK: [[COND_END21]]:
// CHECK-NOT: phi
// CHECK-NOT: store
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNC_CONT:.+]]

// CHECK: [[SYNC_CONT]]:
// CHECK-NEXT: %[[V8:.+]] = load i32, ptr %[[VALUE1]]
// CHECK-NEXT: %[[V9:.+]] = load i32, ptr %[[VALUE2]]
// CHECK-NEXT: %[[ADD:.+]] = add nsw i32 %[[V8]], %[[V9]]
// CHECK-NEXT: %[[V10:.+]] = load i32, ptr %[[VALUE3]]
// CHECK-NEXT: %[[SUB:.+]] = sub nsw i32 %[[ADD]], %[[V10]]
// CHECK-NEXT: %[[V11:.+]] = load i32, ptr %[[VALUE4]]
// CHECK-NEXT: %[[SUB22:.+]] = sub nsw i32 %[[SUB]], %[[V11]]
// CHECK: ret i32 %[[SUB22]]


int test_nested_conditional_expression(int some_condition, int other_condition) {
    // Test nested conditional expressions
    int value1, value3;
    value1 = some_condition ? other_condition ? cilk_spawn get_value() : 1 : 2;
    int value2 = !some_condition ? !other_condition ? 2 : cilk_spawn get_value() : 1;
    value3 = some_condition ? !other_condition ? 1 : cilk_spawn get_value() : 2;
    cilk_sync;
    return value1 + value2 - value3;
}

// CHECK-LABEL: define {{.*}}i32 @test_nested_conditional_expression(
// CHECK: %[[SOME_CONDITION_ADDR:.+]] = alloca i32
// CHECK: %[[OTHER_CONDITION_ADDR:.+]] = alloca i32
// CHECK: %[[VALUE1:.+]] = alloca i32
// CHECK: %[[VALUE3:.+]] = alloca i32
// CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
// CHECK: %[[VALUE2:.+]] = alloca i32
// CHECK: br i1 %[[TOBOOL:.+]], label %[[COND_TRUE:.+]], label %[[COND_FALSE3:.+]]

// CHECK: [[COND_TRUE]]:
// CHECK: br i1 %[[TOBOOL1:.+]], label %[[COND_TRUE2:.+]], label %[[COND_FALSE:.+]]

// CHECK: [[COND_TRUE2]]:
// CHECK-NEXT: %[[TF2:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]]

// CHECK: [[DETACHED]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF2]])
// CHECK-NEXT: %[[CALL:.+]] = call {{.*}}i32 @get_value()
// CHECK-NEXT: store i32 %[[CALL]], ptr %[[VALUE1]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK-NEXT: br label %[[COND_END:.+]]

// CHECK: [[COND_FALSE]]:
// CHECK-NEXT: store i32 1, ptr %[[VALUE1]]
// CHECK-NEXT: br label %[[COND_END]]

// CHECK: [[COND_END]]:
// CHECK-NOT: phi
// CHECK-NOT: store
// CHECK-NEXT: br label %[[COND_END4:.+]]

// CHECK: [[COND_FALSE3]]:
// CHECK-NEXT: store i32 2, ptr %[[VALUE1]]
// CHECK-NEXT: br label %[[COND_END4]]

// CHECK: [[COND_END4]]:
// CHECK-NOT: phi
// CHECK-NOT: store
// CHECK: br i1 %[[TOBOOL5:.+]], label %[[COND_FALSE14:.+]], label %[[COND_TRUE6:.+]]

// CHECK: [[COND_TRUE6]]:
// CHECK: br i1 %[[TOBOOL7:.+]], label %[[COND_FALSE9:.+]], label %[[COND_TRUE8:.+]]

// CHECK: [[COND_TRUE8]]:
// CHECK-NEXT: store i32 2, ptr %[[VALUE2]]
// CHECK-NEXT: br label %[[COND_END13:.+]]

// CHECK: [[COND_FALSE9]]:
// CHECK-NEXT: %[[TF5:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED10:.+]], label %[[CONTINUE12:.+]]

// CHECK: [[DETACHED10]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF5]])
// CHECK-NEXT: %[[CALL11:.+]] = call {{.*}}i32 @get_value()
// CHECK-NEXT: store i32 %[[CALL11]], ptr %[[VALUE2]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE12]]

// CHECK: [[CONTINUE12]]:
// CHECK-NEXT: br label %[[COND_END13]]

// CHECK: [[COND_END13]]:
// CHECK-NOT: phi
// CHECK-NOT: store
// CHECK-NEXT: br label %[[COND_END15:.+]]

// CHECK: [[COND_FALSE14]]:
// CHECK-NEXT: store i32 1, ptr %[[VALUE2]]
// CHECK-NEXT: br label %[[COND_END15]]

// CHECK: [[COND_END15]]:
// CHECK-NOT: phi
// CHECK-NOT: store
// CHECK: br i1 %[[TOBOOL16:.+]], label %[[COND_TRUE17:.+]], label %[[COND_FALSE25:.+]]

// CHECK: [[COND_TRUE17]]:
// CHECK: br i1 %[[TOBOOL18:.+]], label %[[COND_FALSE20:.+]], label %[[COND_TRUE19:.+]]

// CHECK: [[COND_TRUE19]]:
// CHECK-NEXT: store i32 1, ptr %[[VALUE3]]
// CHECK-NEXT: br label %[[COND_END24:.+]]

// CHECK: [[COND_FALSE20]]:
// CHECK-NEXT: %[[TF8:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED21:.+]], label %[[CONTINUE23:.+]]

// CHECK: [[DETACHED21]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF8]])
// CHECK-NEXT: %[[CALL22:.+]] = call {{.*}}i32 @get_value()
// CHECK-NEXT: store i32 %[[CALL22]], ptr %[[VALUE3]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE23]]

// CHECK: [[CONTINUE23]]:
// CHECK-NEXT: br label %[[COND_END24]]

// CHECK: [[COND_END24]]:
// CHECK-NOT: phi
// CHECK-NOT: store
// CHECK-NEXT: br label %[[COND_END26:.+]]

// CHECK: [[COND_FALSE25]]:
// CHECK-NEXT: store i32 2, ptr %[[VALUE3]]
// CHECK-NEXT: br label %[[COND_END26]]

// CHECK: [[COND_END26]]:
// CHECK-NOT: phi
// CHECK-NOT: store
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNC_CONT:.+]]

// CHECK: [[SYNC_CONT]]:
// CHECK-NEXT: %[[V9:.+]] = load i32, ptr %[[VALUE1]]
// CHECK-NEXT: %[[V10:.+]] = load i32, ptr %[[VALUE2]]
// CHECK-NEXT: %[[ADD:.+]] = add nsw i32 %[[V9]], %[[V10]]
// CHECK-NEXT: %[[V11:.+]] = load i32, ptr %[[VALUE3]]
// CHECK-NEXT: %[[SUB:.+]] = sub nsw i32 %[[ADD]], %[[V11]]
// CHECK: ret i32 %[[SUB]]
