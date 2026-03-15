// Check code generation of cilk_spawn in conditional expressions.
//
// RUN: %clang_cc1 %s -triple x86_64-unknown-linux-gnu -fopencilk -fcxx-exceptions -fexceptions -ftapir=none -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

class Object {
  int x;

public:
  Object();
  ~Object();
};

int get_value(void) { return 42; }

int throw_value(void) { throw 42; }

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

// CHECK-LABEL: define {{.*}}i32 @_Z27test_conditional_expressioni(
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
// CHECK-NEXT: %[[CALL:.+]] = call {{.*}}i32 @_Z9get_valuev()
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
// CHECK-NEXT: %[[CALL4:.+]] = call {{.*}}i32 @_Z9get_valuev()
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
// CHECK-NEXT: %[[CALL12:.+]] = call {{.*}}i32 @_Z9get_valuev()
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
// CHECK-NEXT: %[[CALL19:.+]] = call {{.*}}i32 @_Z9get_valuev()
// CHECK-NEXT: store i32 %[[CALL19]], ptr %[[VALUE4]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE20]]

// CHECK: [[CONTINUE20]]:
// CHECK-NEXT: br label %[[COND_END21]]

// CHECK: [[COND_END21]]:
// CHECK-NOT: phi
// CHECK-NOT: store
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNC_CONT:.+]]

// CHECK: [[SYNC_CONT]]:
// CHECK-NEXT: call void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: %[[V8:.+]] = load i32, ptr %[[VALUE1]]
// CHECK-NEXT: %[[V9:.+]] = load i32, ptr %[[VALUE2]]
// CHECK-NEXT: %[[ADD:.+]] = add nsw i32 %[[V8]], %[[V9]]
// CHECK-NEXT: %[[V10:.+]] = load i32, ptr %[[VALUE3]]
// CHECK-NEXT: %[[SUB:.+]] = sub nsw i32 %[[ADD]], %[[V10]]
// CHECK-NEXT: %[[V11:.+]] = load i32, ptr %[[VALUE4]]
// CHECK-NEXT: %[[SUB22:.+]] = sub nsw i32 %[[SUB]], %[[V11]]
// CHECK: ret i32 %[[SUB22]]


int test_constexpr_conditional_expression() {
    // Test conditional expressions with constexpr conditions
    constexpr int some_condition = 1;
    int value1, value3;
    value1 = some_condition ? cilk_spawn get_value() : 1;
    int value2 = !some_condition ? cilk_spawn get_value() : 2;
    value3 = some_condition ? 1: cilk_spawn get_value();
    int value4 = !some_condition ? 2: cilk_spawn get_value();
    cilk_sync;
    return value1 + value2 - value3 - value4;
}

// CHECK-LABEL: define {{.*}}i32 @_Z37test_constexpr_conditional_expressionv(
// CHECK: %[[SOME_CONDITION:.+]] = alloca i32
// CHECK: %[[VALUE1:.+]] = alloca i32
// CHECK: %[[VALUE3:.+]] = alloca i32
// CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
// CHECK: %[[VALUE2:.+]] = alloca i32
// CHECK: %[[VALUE4:.+]] = alloca i32
// CHECK: store i32 1, ptr %[[SOME_CONDITION]]
// CHECK: %[[TF0:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]]

// CHECK: [[DETACHED]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF0]])
// CHECK-NEXT: %[[CALL:.+]] = call {{.*}}i32 @_Z9get_valuev()
// CHECK-NEXT: store i32 %[[CALL]], ptr %[[VALUE1]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK-NEXT: store i32 2, ptr %[[VALUE2]]
// CHECK-NEXT: store i32 1, ptr %[[VALUE3]]
// CHECK-NEXT: %[[TF1:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED1:.+]], label %[[CONTINUE3:.+]]

// CHECK: [[DETACHED1]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF1]])
// CHECK-NEXT: %[[CALL2:.+]] = call {{.*}}i32 @_Z9get_valuev()
// CHECK-NEXT: store i32 %[[CALL2]], ptr %[[VALUE4]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE3]]

// CHECK: [[CONTINUE3]]:
// CHECK-NOT: phi
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNC_CONT:.+]]

// CHECK: [[SYNC_CONT]]:
// CHECK-NEXT: call void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: %[[V2:.+]] = load i32, ptr %[[VALUE1]]
// CHECK-NEXT: %[[V3:.+]] = load i32, ptr %[[VALUE2]]
// CHECK-NEXT: %[[ADD:.+]] = add nsw i32 %[[V2]], %[[V3]]
// CHECK-NEXT: %[[V4:.+]] = load i32, ptr %[[VALUE3]]
// CHECK-NEXT: %[[SUB:.+]] = sub nsw i32 %[[ADD]], %[[V4]]
// CHECK-NEXT: %[[V5:.+]] = load i32, ptr %[[VALUE4]]
// CHECK-NEXT: %[[SUB4:.+]] = sub nsw i32 %[[SUB]], %[[V5]]
// CHECK: ret i32 %[[SUB4]]


int test_nested_conditional_expression(int some_condition, int other_condition) {
    // Test nested conditional expressions
    int value1, value3;
    value1 = some_condition ? other_condition ? cilk_spawn get_value() : 1 : 2;
    int value2 = !some_condition ? !other_condition ? 2 : cilk_spawn get_value() : 1;
    value3 = some_condition ? !other_condition ? 1 : cilk_spawn get_value() : 2;
    cilk_sync;
    return value1 + value2 - value3;
}

// CHECK-LABEL: define {{.*}}i32 @_Z34test_nested_conditional_expressionii(
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
// CHECK-NEXT: %[[CALL:.+]] = call {{.*}}i32 @_Z9get_valuev()
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
// CHECK-NEXT: %[[CALL11:.+]] = call {{.*}}i32 @_Z9get_valuev()
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
// CHECK-NEXT: %[[CALL22:.+]] = call {{.*}}i32 @_Z9get_valuev()
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
// CHECK-NEXT: call void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: %[[V9:.+]] = load i32, ptr %[[VALUE1]]
// CHECK-NEXT: %[[V10:.+]] = load i32, ptr %[[VALUE2]]
// CHECK-NEXT: %[[ADD:.+]] = add nsw i32 %[[V9]], %[[V10]]
// CHECK-NEXT: %[[V11:.+]] = load i32, ptr %[[VALUE3]]
// CHECK-NEXT: %[[SUB:.+]] = sub nsw i32 %[[ADD]], %[[V11]]
// CHECK: ret i32 %[[SUB]]


int test_nested_constexpr_conditional_expression() {
    // Test nested conditional expressions with constexpr conditions
    constexpr int some_condition = 1, other_condition = 0;
    int value1, value3;
    value1 = some_condition ? other_condition ? cilk_spawn get_value() : 1 : 2;
    int value2 = !some_condition ? !other_condition ? cilk_spawn get_value() : 1 : 2;
    value3 = some_condition ? !other_condition ? cilk_spawn get_value() : 1 : 2;
    cilk_sync;
    return value1 + value2 - value3;
}

// CHECK-LABEL: define {{.*}}i32 @_Z44test_nested_constexpr_conditional_expressionv(
// CHECK: %[[SOME_CONDITION:.+]] = alloca i32
// CHECK: %[[OTHER_CONDITION:.+]] = alloca i32
// CHECK: %[[VALUE1:.+]] = alloca i32
// CHECK: %[[VALUE3:.+]] = alloca i32
// CHECK: %[[VALUE2:.+]] = alloca i32
// CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
// CHECK: store i32 1, ptr %[[SOME_CONDITION]]
// CHECK: store i32 0, ptr %[[OTHER_CONDITION]]
// CHECK-NEXT: store i32 1, ptr %[[VALUE1]]
// CHECK-NEXT: store i32 2, ptr %[[VALUE2]]
// CHECK-NEXT: %[[TF0:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]]

// CHECK: [[DETACHED]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF0]])
// CHECK-NEXT: %[[CALL:.+]] = call {{.*}}i32 @_Z9get_valuev()
// CHECK-NEXT: store i32 %[[CALL]], ptr %[[VALUE3]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK-NOT: phi
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNC_CONT:.+]]

// CHECK: [[SYNC_CONT]]:
// CHECK-NEXT: call void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: %[[V1:.+]] = load i32, ptr %[[VALUE1]]
// CHECK-NEXT: %[[V2:.+]] = load i32, ptr %[[VALUE2]]
// CHECK-NEXT: %[[ADD:.+]] = add nsw i32 %[[V1]], %[[V2]]
// CHECK-NEXT: %[[V3:.+]] = load i32, ptr %[[VALUE3]]
// CHECK-NEXT: %[[SUB:.+]] = sub nsw i32 %[[ADD]], %[[V3]]
// CHECK: ret i32 %[[SUB]]


int test_object_destruction_conditional_expression(int some_condition) {
    Object o;
    // Test object destruction on exceptional paths out of conditional
    // expressions
    int value1;
    value1 = some_condition ? cilk_spawn throw_value() : cilk_spawn get_value();
    int value2 = !some_condition ? 2 : cilk_spawn throw_value();

    constexpr int other_condition = 0;
    int value3;
    value3 = other_condition ? cilk_spawn throw_value() : 1;
    int value4 = other_condition ? 2 : cilk_spawn throw_value();

    cilk_sync;
    return value1 + value2 - value3 - value4;
}

// CHECK-LABEL: define {{.*}}i32 @_Z46test_object_destruction_conditional_expressioni(
// CHECK: %[[SOME_CONDITION_ADDR:.+]] = alloca i32
// CHECK: %[[O:.+]] = alloca %class.Object
// CHECK: %[[VALUE1:.+]] = alloca i32
// CHECK: %[[SYNCREG:.+]] = call token @llvm.syncregion.start()
// CHECK: %[[EXN_SLOT10:.+]] = alloca ptr
// CHECK: %[[EHSELECTOR_SLOT11:.+]] = alloca i32
// CHECK: %[[VALUE2:.+]] = alloca i32
// CHECK: %[[OTHER_CONDITION:.+]] = alloca i32
// CHECK: %[[VALUE3:.+]] = alloca i32
// CHECK: %[[VALUE4:.+]] = alloca i32
// CHECK: call void @_ZN6ObjectC1Ev(ptr {{.*}}%[[O]])
// CHECK: br i1 %[[TOBOOL:.+]], label %[[COND_TRUE:.+]], label %[[COND_FALSE:.+]]

// CHECK: [[COND_TRUE]]:
// CHECK-NEXT: %[[TF1:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: %[[EXN_SLOT3:.+]] = alloca ptr
// CHECK-NEXT: %[[EHSELECTOR_SLOT4:.+]] = alloca i32
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED:.+]], label %[[CONTINUE:.+]] unwind label %[[LPAD2:.+]]

// CHECK: [[DETACHED]]:
// CHECK-NEXT: %[[EXN_SLOT:.+]] = alloca ptr
// CHECK-NEXT: %[[EHSELECTOR_SLOT:.+]] = alloca i32
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF1]])
// CHECK-NEXT: %[[CALL:.+]] = invoke {{.*}}i32 @_Z11throw_valuev()
// CHECK-NEXT: to label %[[INVOKE_CONT:.+]] unwind label %[[LPAD:.+]]

// CHECK: [[INVOKE_CONT]]:
// CHECK-NEXT: store i32 %[[CALL]], ptr %[[VALUE1]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE]]

// CHECK: [[CONTINUE]]:
// CHECK-NEXT: br label %[[COND_END:.+]]

// CHECK: [[COND_FALSE]]:
// CHECK-NEXT: %[[TF2:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED12:.+]], label %[[CONTINUE14:.+]]

// CHECK: [[DETACHED12]]:
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF2]])
// CHECK-NEXT: %[[CALL13:.+]] = call {{.*}}i32 @_Z9get_valuev()
// CHECK-NEXT: store i32 %[[CALL13]], ptr %[[VALUE1]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE14]]

// CHECK: [[CONTINUE14]]:
// CHECK-NEXT: br label %[[COND_END]]

// CHECK: [[COND_END]]:
// CHECK-NOT: phi
// CHECK-NOT: store
// CHECK: br i1 %[[TOBOOL15:.+]], label %[[COND_FALSE17:.+]], label %[[COND_TRUE16:.+]]

// CHECK: [[COND_TRUE16]]:
// CHECK-NEXT: store i32 2, ptr %[[VALUE2]]
// CHECK-NEXT: br label %[[COND_END38:.+]]

// CHECK: [[COND_FALSE17]]:
// CHECK-NEXT: %[[TF4:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: %[[EXN_SLOT30:.+]] = alloca ptr
// CHECK-NEXT: %[[EHSELECTOR_SLOT31:.+]] = alloca i32
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED18:.+]], label %[[CONTINUE32:.+]] unwind label %[[LPAD29:.+]]

// CHECK: [[DETACHED18]]:
// CHECK-NEXT: %[[EXN_SLOT20:.+]] = alloca ptr
// CHECK-NEXT: %[[EHSELECTOR_SLOT21:.+]] = alloca i32
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF4]])
// CHECK-NEXT: %[[CALL23:.+]] = invoke {{.*}}i32 @_Z11throw_valuev()
// CHECK-NEXT: to label %[[INVOKE_CONT22:.+]] unwind label %[[LPAD19:.+]]

// CHECK: [[INVOKE_CONT22]]:
// CHECK-NEXT: store i32 %[[CALL23]], ptr %[[VALUE2]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE32]]

// CHECK: [[CONTINUE32]]:
// CHECK-NEXT: br label %[[COND_END38]]

// CHECK: [[COND_END38]]:
// CHECK-NOT: phi
// CHECK: store i32 1, ptr %[[VALUE3]]
// CHECK-NEXT: %[[TF5:.+]] = call token @llvm.taskframe.create()
// CHECK-NEXT: %[[EXN_SLOT51:.+]] = alloca ptr
// CHECK-NEXT: %[[EHSELECTOR_SLOT52:.+]] = alloca i32
// CHECK-NEXT: detach within %[[SYNCREG]], label %[[DETACHED39:.+]], label %[[CONTINUE53:.+]] unwind label %[[LPAD50:.+]]

// CHECK: [[DETACHED39]]:
// CHECK-NEXT: %[[EXN_SLOT41:.+]] = alloca ptr
// CHECK-NEXT: %[[EHSELECTOR_SLOT42:.+]] = alloca i32
// CHECK-NEXT: call void @llvm.taskframe.use(token %[[TF5]])
// CHECK-NEXT: %[[CALL44:.+]] = invoke {{.*}}i32 @_Z11throw_valuev()
// CHECK-NEXT: to label %[[INVOKE_CONT43:.+]] unwind label %[[LPAD40:.+]]

// CHECK: [[INVOKE_CONT43]]:
// CHECK-NEXT: store i32 %[[CALL44]], ptr %[[VALUE4]]
// CHECK-NEXT: reattach within %[[SYNCREG]], label %[[CONTINUE53]]

// CHECK: [[CONTINUE53]]:
// CHECK-NOT: store
// CHECK-NEXT: sync within %[[SYNCREG]], label %[[SYNC_CONT:.+]]

// CHECK: [[SYNC_CONT]]:
// CHECK-NEXT: invoke void @llvm.sync.unwind(token %[[SYNCREG]])
// CHECK-NEXT: to label %[[INVOKE_CONT59:.+]] unwind label %[[LPAD9:.+]]

// CHECK: [[INVOKE_CONT59]]:
// CHECK-NEXT: %[[V6:.+]] = load i32, ptr %[[VALUE1]]
// CHECK-NEXT: %[[V7:.+]] = load i32, ptr %[[VALUE2]]
// CHECK-NEXT: %[[ADD:.+]] = add nsw i32 %[[V6]], %[[V7]]
// CHECK-NEXT: %[[V8:.+]] = load i32, ptr %[[VALUE3]]
// CHECK-NEXT: %[[SUB:.+]] = sub nsw i32 %[[ADD]], %[[V8]]
// CHECK-NEXT: %[[V9:.+]] = load i32, ptr %[[VALUE4]]
// CHECK-NEXT: %[[SUB60:.+]] = sub nsw i32 %[[SUB]], %[[V9]]

// CHECK: [[LPAD]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: store ptr %{{.+}}, ptr %[[EXN_SLOT]]
// CHECK: store i32 %{{.+}}, ptr %[[EHSELECTOR_SLOT]]
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE:.+]] unwind label %[[LPAD2]]

// CHECK: [[LPAD2]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: store ptr %{{.+}}, ptr %[[EXN_SLOT3]]
// CHECK: store i32 %{{.+}}, ptr %[[EHSELECTOR_SLOT4]]
// CHECK: br label %[[EHCLEANUP:.+]]

// CHECK: [[EHCLEANUP]]:
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF1]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[LPAD9]]

// CHECK: [[LPAD9]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: store ptr %{{.+}}, ptr %[[EXN_SLOT10]]
// CHECK: store i32 %{{.+}}, ptr %[[EHSELECTOR_SLOT11]]
// CHECK: call void @_ZN6ObjectD1Ev(ptr {{.*}}%[[O]])
// CHECK-NEXT: br label %[[EH_RESUME:.+]]

// CHECK: [[LPAD19]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: store ptr %{{.+}}, ptr %[[EXN_SLOT20]]
// CHECK: store i32 %{{.+}}, ptr %[[EHSELECTOR_SLOT21]]
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[LPAD29]]

// CHECK: [[LPAD29]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: store ptr %{{.+}}, ptr %[[EXN_SLOT30]]
// CHECK: store i32 %{{.+}}, ptr %[[EHSELECTOR_SLOT31]]
// CHECK: br label %[[EHCLEANUP33:.+]]

// CHECK: [[EHCLEANUP33]]:
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF4]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[LPAD9]]

// CHECK: [[LPAD40]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: store ptr %{{.+}}, ptr %[[EXN_SLOT41]]
// CHECK: store i32 %{{.+}}, ptr %[[EHSELECTOR_SLOT42]]
// CHECK: invoke void @llvm.detached.rethrow.sl_p0i32s(token %[[SYNCREG]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[LPAD50]]

// CHECK: [[LPAD50]]:
// CHECK-NEXT: landingpad
// CHECK-NEXT: cleanup
// CHECK: store ptr %{{.+}}, ptr %[[EXN_SLOT51]]
// CHECK: store i32 %{{.+}}, ptr %[[EHSELECTOR_SLOT52]]
// CHECK: br label %[[EHCLEANUP54:.+]]

// CHECK: [[EHCLEANUP54]]:
// CHECK: invoke void @llvm.taskframe.resume.sl_p0i32s(token %[[TF5]],
// CHECK-NEXT: to label %[[UNREACHABLE]] unwind label %[[LPAD9]]

// CHECK: ret i32 %[[SUB60]]

// CHECK: [[EH_RESUME]]:
// CHECK: resume

// CHECK: [[UNREACHABLE]]:
// CHECK: unreachable