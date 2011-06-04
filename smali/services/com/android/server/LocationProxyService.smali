.class public Lcom/android/server/LocationProxyService;
.super Lcom/motorola/android/locationproxy/ILocationProxy$Stub;
.source "LocationProxyService.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/android/server/LocationProxyService$1;,
        Lcom/android/server/LocationProxyService$ProxyWorkerHandler;
    }
.end annotation


# static fields
.field private static final ACCESS_FINE_LOCATION:Ljava/lang/String; = "android.permission.ACCESS_FINE_LOCATION"

.field private static final MTLR_PERMISSION_DENIED:I = 0x0

.field private static final MTLR_PERMISSION_GRANTED:I = 0x1

.field private static final RECEIVE_MTLR_LOCATION:Ljava/lang/String; = "android.permission.RECEIVE_MTLR_LOCATION"

.field private static final TAG:Ljava/lang/String; = "LocationProxyService"


# instance fields
.field private final mContext:Landroid/content/Context;

.field private mListener:Lcom/motorola/android/locationproxy/IMtlrListener;

.field private mProxyHandler:Lcom/android/server/LocationProxyService$ProxyWorkerHandler;

.field private mSuplCommands:Lcom/motorola/android/locationproxy/ISuplCommands;

.field private mSuplDataService:Lcom/motorola/android/locationproxy/SuplDataService;

.field private mWapPushReceiver:Lcom/motorola/android/locationproxy/SuplWapPushReceiver;


# direct methods
.method public constructor <init>(Landroid/content/Context;)V
    .locals 4
    .parameter "context"

    .prologue
    const/4 v2, 0x0

    const-string v3, "LocationProxyService"

    .line 67
    invoke-direct {p0}, Lcom/motorola/android/locationproxy/ILocationProxy$Stub;-><init>()V

    .line 54
    iput-object v2, p0, Lcom/android/server/LocationProxyService;->mWapPushReceiver:Lcom/motorola/android/locationproxy/SuplWapPushReceiver;

    .line 55
    iput-object v2, p0, Lcom/android/server/LocationProxyService;->mSuplDataService:Lcom/motorola/android/locationproxy/SuplDataService;

    .line 56
    iput-object v2, p0, Lcom/android/server/LocationProxyService;->mSuplCommands:Lcom/motorola/android/locationproxy/ISuplCommands;

    .line 57
    iput-object v2, p0, Lcom/android/server/LocationProxyService;->mProxyHandler:Lcom/android/server/LocationProxyService$ProxyWorkerHandler;

    .line 58
    iput-object v2, p0, Lcom/android/server/LocationProxyService;->mListener:Lcom/motorola/android/locationproxy/IMtlrListener;

    .line 68
    iput-object p1, p0, Lcom/android/server/LocationProxyService;->mContext:Landroid/content/Context;

    .line 70
    new-instance v0, Ljava/lang/Thread;

    const-string v1, "LocationProxyService"

    invoke-direct {v0, v2, p0, v3}, Ljava/lang/Thread;-><init>(Ljava/lang/ThreadGroup;Ljava/lang/Runnable;Ljava/lang/String;)V

    .line 71
    .local v0, thread:Ljava/lang/Thread;
    invoke-virtual {v0}, Ljava/lang/Thread;->start()V

    .line 74
    const-string v1, "LocationProxyService"

    const-string v1, "Constructed LocationProxyService"

    invoke-static {v3, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 77
    return-void
.end method

.method private _getSuplServer(Z)Ljava/lang/String;
    .locals 5
    .parameter "defaultSupl"

    .prologue
    const-string v4, "LocationProxyService"

    .line 105
    const-string v3, "LocationProxyService"

    const-string v3, "Enter: _getSuplServer()"

    invoke-static {v4, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 106
    const/4 v1, 0x0

    .line 108
    .local v1, fqdn:Ljava/lang/String;
    :try_start_0
    invoke-direct {p0}, Lcom/android/server/LocationProxyService;->checkPermission()V

    .line 109
    if-eqz p1, :cond_0

    .line 110
    iget-object v3, p0, Lcom/android/server/LocationProxyService;->mSuplCommands:Lcom/motorola/android/locationproxy/ISuplCommands;

    invoke-interface {v3}, Lcom/motorola/android/locationproxy/ISuplCommands;->getDefaultConfigFQDN()Ljava/lang/String;
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    move-result-object v1

    .line 121
    :goto_0
    const-string v3, "LocationProxyService"

    const-string v3, "OK: Leave _getSuplServer()"

    invoke-static {v4, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 122
    return-object v1

    .line 113
    :cond_0
    :try_start_1
    iget-object v3, p0, Lcom/android/server/LocationProxyService;->mSuplCommands:Lcom/motorola/android/locationproxy/ISuplCommands;

    invoke-interface {v3}, Lcom/motorola/android/locationproxy/ISuplCommands;->getUserConfigFQDN()Ljava/lang/String;
    :try_end_1
    .catch Ljava/lang/SecurityException; {:try_start_1 .. :try_end_1} :catch_0
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    move-result-object v1

    goto :goto_0

    .line 115
    :catch_0
    move-exception v3

    move-object v2, v3

    .line 116
    .local v2, se:Ljava/lang/SecurityException;
    const-string v3, "LocationProxyService"

    const-string v3, "got SecurityException!"

    invoke-static {v4, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 117
    throw v2

    .line 118
    .end local v2           #se:Ljava/lang/SecurityException;
    :catch_1
    move-exception v3

    move-object v0, v3

    .line 119
    .local v0, e:Ljava/lang/Exception;
    const-string v3, "LocationProxyService"

    const-string v3, "got Exception!"

    invoke-static {v4, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method

.method static synthetic access$000(Lcom/android/server/LocationProxyService;Landroid/os/Message;)V
    .locals 0
    .parameter "x0"
    .parameter "x1"

    .prologue
    .line 43
    invoke-direct {p0, p1}, Lcom/android/server/LocationProxyService;->sendMtlrBroadcast(Landroid/os/Message;)V

    return-void
.end method

.method static synthetic access$100(Lcom/android/server/LocationProxyService;Landroid/os/Message;)V
    .locals 0
    .parameter "x0"
    .parameter "x1"

    .prologue
    .line 43
    invoke-direct {p0, p1}, Lcom/android/server/LocationProxyService;->sendMtlrBroadcast2(Landroid/os/Message;)V

    return-void
.end method

.method static synthetic access$200(Lcom/android/server/LocationProxyService;)Lcom/motorola/android/locationproxy/IMtlrListener;
    .locals 1
    .parameter "x0"

    .prologue
    .line 43
    iget-object v0, p0, Lcom/android/server/LocationProxyService;->mListener:Lcom/motorola/android/locationproxy/IMtlrListener;

    return-object v0
.end method

.method private checkMtlrPermission()V
    .locals 2

    .prologue
    .line 307
    iget-object v0, p0, Lcom/android/server/LocationProxyService;->mContext:Landroid/content/Context;

    const-string v1, "android.permission.RECEIVE_MTLR_LOCATION"

    invoke-virtual {v0, v1}, Landroid/content/Context;->checkCallingPermission(Ljava/lang/String;)I

    move-result v0

    if-eqz v0, :cond_0

    .line 309
    const-string v0, "LocationProxyService"

    const-string v1, "*** required permisson: RECEIVE_MTLR_LOCATION"

    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 310
    new-instance v0, Ljava/lang/SecurityException;

    const-string v1, "Requires RECEIVE_MTLR_LOCATION permission"

    invoke-direct {v0, v1}, Ljava/lang/SecurityException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 312
    :cond_0
    return-void
.end method

.method private checkPermission()V
    .locals 2

    .prologue
    .line 299
    iget-object v0, p0, Lcom/android/server/LocationProxyService;->mContext:Landroid/content/Context;

    const-string v1, "android.permission.ACCESS_FINE_LOCATION"

    invoke-virtual {v0, v1}, Landroid/content/Context;->checkCallingPermission(Ljava/lang/String;)I

    move-result v0

    if-eqz v0, :cond_0

    .line 301
    const-string v0, "LocationProxyService"

    const-string v1, "*** required permisson: ACCESS_FINE_LOCATION"

    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 302
    new-instance v0, Ljava/lang/SecurityException;

    const-string v1, "Requires ACCESS_FINE_LOCATION permission"

    invoke-direct {v0, v1}, Ljava/lang/SecurityException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 304
    :cond_0
    return-void
.end method

.method private sendMtlrBroadcast(Landroid/os/Message;)V
    .locals 12
    .parameter "mtlrMsg"

    .prologue
    const-string v11, "LocationProxyService"

    .line 241
    const-string v9, "LocationProxyService"

    const-string v9, "Enter sendMtlrBroadcast"

    invoke-static {v11, v9}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 242
    iget-object v2, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v2, Landroid/os/AsyncResult;

    .line 243
    .local v2, ar:Landroid/os/AsyncResult;
    iget-object v9, v2, Landroid/os/AsyncResult;->result:Ljava/lang/Object;

    check-cast v9, [Ljava/lang/Object;

    move-object v0, v9

    check-cast v0, [Ljava/lang/Object;

    move-object v4, v0

    .line 244
    .local v4, data:[Ljava/lang/Object;
    const/4 v9, 0x0

    aget-object v7, v4, v9

    check-cast v7, Ljava/lang/Integer;

    .line 245
    .local v7, mtlrId:Ljava/lang/Integer;
    const/4 v9, 0x1

    aget-object v8, v4, v9

    check-cast v8, Ljava/lang/Integer;

    .line 246
    .local v8, notificationType:Ljava/lang/Integer;
    const/4 v9, 0x2

    aget-object v6, v4, v9

    check-cast v6, Ljava/lang/Integer;

    .line 247
    .local v6, locationType:Ljava/lang/Integer;
    const/4 v9, 0x3

    aget-object v3, v4, v9

    check-cast v3, Ljava/lang/String;

    .line 248
    .local v3, clientName:Ljava/lang/String;
    const/4 v9, 0x4

    aget-object v1, v4, v9

    check-cast v1, Ljava/lang/String;

    .line 250
    .local v1, address:Ljava/lang/String;
    const-string v9, "LocationProxyService"

    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "mtlrId="

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, ",notificationType="

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, ",locationType="

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, ",clientName="

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, ",address="

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v9

    invoke-static {v11, v9}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 257
    new-instance v5, Landroid/content/Intent;

    const-string v9, "com.motorola.android.locationproxy.MTLR_RECEIVED"

    invoke-direct {v5, v9}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 258
    .local v5, intent:Landroid/content/Intent;
    const-string v9, "mtlrId"

    invoke-virtual {v7}, Ljava/lang/Integer;->intValue()I

    move-result v10

    invoke-virtual {v5, v9, v10}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 259
    const-string v9, "notificationType"

    invoke-virtual {v8}, Ljava/lang/Integer;->intValue()I

    move-result v10

    invoke-virtual {v5, v9, v10}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 260
    const-string v9, "locationType"

    invoke-virtual {v6}, Ljava/lang/Integer;->intValue()I

    move-result v10

    invoke-virtual {v5, v9, v10}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 261
    const-string v9, "clientName"

    invoke-virtual {v5, v9, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 262
    const-string v9, "clientAddress"

    invoke-virtual {v5, v9, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 264
    iget-object v9, p0, Lcom/android/server/LocationProxyService;->mContext:Landroid/content/Context;

    const-string v10, "android.permission.RECEIVE_MTLR_LOCATION"

    invoke-virtual {v9, v5, v10}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;Ljava/lang/String;)V

    .line 266
    const-string v9, "LocationProxyService"

    const-string v9, "Leave sendMtlrBroadcast"

    invoke-static {v11, v9}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 267
    return-void
.end method

.method private sendMtlrBroadcast2(Landroid/os/Message;)V
    .locals 12
    .parameter "mtlrMsg"

    .prologue
    const-string v11, "LocationProxyService"

    .line 270
    const-string v9, "LocationProxyService"

    const-string v9, "Enter sendMtlrBroadcast2"

    invoke-static {v11, v9}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 271
    iget-object v2, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v2, Landroid/os/AsyncResult;

    .line 272
    .local v2, ar:Landroid/os/AsyncResult;
    iget-object v9, v2, Landroid/os/AsyncResult;->result:Ljava/lang/Object;

    check-cast v9, [Ljava/lang/Object;

    move-object v0, v9

    check-cast v0, [Ljava/lang/Object;

    move-object v4, v0

    .line 274
    .local v4, data:[Ljava/lang/Object;
    const/4 v9, 0x0

    aget-object v7, v4, v9

    check-cast v7, Ljava/lang/Integer;

    .line 275
    .local v7, mtlrId:Ljava/lang/Integer;
    const/4 v9, 0x1

    aget-object v8, v4, v9

    check-cast v8, Ljava/lang/Integer;

    .line 276
    .local v8, notificationType:Ljava/lang/Integer;
    const/4 v9, 0x2

    aget-object v6, v4, v9

    check-cast v6, Ljava/lang/Integer;

    .line 277
    .local v6, locationType:Ljava/lang/Integer;
    const/4 v9, 0x5

    aget-object v3, v4, v9

    check-cast v3, Ljava/lang/String;

    .line 278
    .local v3, clientName:Ljava/lang/String;
    const/4 v9, 0x7

    aget-object v1, v4, v9

    check-cast v1, Ljava/lang/String;

    .line 280
    .local v1, address:Ljava/lang/String;
    const-string v9, "LocationProxyService"

    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "mtlrId="

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, ",notificationType="

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, ",locationType="

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, ",clientName="

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, ",address="

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v9

    invoke-static {v11, v9}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 286
    new-instance v5, Landroid/content/Intent;

    const-string v9, "com.motorola.android.locationproxy.MTLR_RECEIVED"

    invoke-direct {v5, v9}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 287
    .local v5, intent:Landroid/content/Intent;
    const-string v9, "mtlrId"

    invoke-virtual {v7}, Ljava/lang/Integer;->intValue()I

    move-result v10

    invoke-virtual {v5, v9, v10}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 288
    const-string v9, "notificationType"

    invoke-virtual {v8}, Ljava/lang/Integer;->intValue()I

    move-result v10

    invoke-virtual {v5, v9, v10}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 289
    const-string v9, "locationType"

    invoke-virtual {v6}, Ljava/lang/Integer;->intValue()I

    move-result v10

    invoke-virtual {v5, v9, v10}, Landroid/content/Intent;->putExtra(Ljava/lang/String;I)Landroid/content/Intent;

    .line 290
    const-string v9, "clientName"

    invoke-virtual {v5, v9, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 291
    const-string v9, "clientAddress"

    invoke-virtual {v5, v9, v1}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 293
    iget-object v9, p0, Lcom/android/server/LocationProxyService;->mContext:Landroid/content/Context;

    const-string v10, "android.permission.RECEIVE_MTLR_LOCATION"

    invoke-virtual {v9, v5, v10}, Landroid/content/Context;->sendBroadcast(Landroid/content/Intent;Ljava/lang/String;)V

    .line 295
    const-string v9, "LocationProxyService"

    const-string v9, "Leave sendMtlrBroadcast2"

    invoke-static {v11, v9}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 296
    return-void
.end method


# virtual methods
.method public getDefaultSuplServer()Ljava/lang/String;
    .locals 5

    .prologue
    const-string v4, "LocationProxyService"

    .line 93
    :try_start_0
    const-string v2, "LocationProxyService"

    const-string v3, "getDefaultSuplServer"

    invoke-static {v2, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 94
    const/4 v2, 0x1

    invoke-direct {p0, v2}, Lcom/android/server/LocationProxyService;->_getSuplServer(Z)Ljava/lang/String;
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    move-result-object v2

    .line 101
    :goto_0
    return-object v2

    .line 95
    :catch_0
    move-exception v2

    move-object v1, v2

    .line 96
    .local v1, se:Ljava/lang/SecurityException;
    throw v1

    .line 97
    .end local v1           #se:Ljava/lang/SecurityException;
    :catch_1
    move-exception v2

    move-object v0, v2

    .line 98
    .local v0, e:Ljava/lang/Exception;
    const-string v2, "LocationProxyService"

    const-string v2, "getSuplServer exception:"

    invoke-static {v4, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 101
    const/4 v2, 0x0

    goto :goto_0
.end method

.method public getSuplServer()Ljava/lang/String;
    .locals 5

    .prologue
    const-string v4, "LocationProxyService"

    .line 81
    :try_start_0
    const-string v2, "LocationProxyService"

    const-string v3, "getSuplServer"

    invoke-static {v2, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 82
    const/4 v2, 0x0

    invoke-direct {p0, v2}, Lcom/android/server/LocationProxyService;->_getSuplServer(Z)Ljava/lang/String;
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    move-result-object v2

    .line 88
    :goto_0
    return-object v2

    .line 83
    :catch_0
    move-exception v2

    move-object v1, v2

    .line 84
    .local v1, se:Ljava/lang/SecurityException;
    throw v1

    .line 85
    .end local v1           #se:Ljava/lang/SecurityException;
    :catch_1
    move-exception v2

    move-object v0, v2

    .line 86
    .local v0, e:Ljava/lang/Exception;
    const-string v2, "LocationProxyService"

    const-string v2, "getSuplServer exception:"

    invoke-static {v4, v2, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 88
    const/4 v2, 0x0

    goto :goto_0
.end method

.method public registerMtlrListener(Lcom/motorola/android/locationproxy/IMtlrListener;)Z
    .locals 2
    .parameter "listener"

    .prologue
    .line 178
    :try_start_0
    invoke-direct {p0}, Lcom/android/server/LocationProxyService;->checkMtlrPermission()V

    .line 179
    iput-object p1, p0, Lcom/android/server/LocationProxyService;->mListener:Lcom/motorola/android/locationproxy/IMtlrListener;
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_0

    .line 184
    const/4 v1, 0x1

    return v1

    .line 181
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 182
    .local v0, se:Ljava/lang/SecurityException;
    throw v0
.end method

.method public resetSuplServer()Z
    .locals 6

    .prologue
    .line 142
    const/4 v2, 0x0

    .line 144
    .local v2, ret:Z
    :try_start_0
    invoke-virtual {p0}, Lcom/android/server/LocationProxyService;->getDefaultSuplServer()Ljava/lang/String;

    move-result-object v0

    .line 145
    .local v0, defaultSupl:Ljava/lang/String;
    if-eqz v0, :cond_0

    .line 146
    invoke-virtual {p0, v0}, Lcom/android/server/LocationProxyService;->setSuplServer(Ljava/lang/String;)Z
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    move-result v2

    .line 153
    .end local v0           #defaultSupl:Ljava/lang/String;
    :cond_0
    :goto_0
    return v2

    .line 148
    :catch_0
    move-exception v4

    move-object v3, v4

    .line 149
    .local v3, se:Ljava/lang/SecurityException;
    throw v3

    .line 150
    .end local v3           #se:Ljava/lang/SecurityException;
    :catch_1
    move-exception v4

    move-object v1, v4

    .line 151
    .local v1, e:Ljava/lang/Exception;
    const-string v4, "LocationProxyService"

    const-string v5, "resetSuplServer got exception:"

    invoke-static {v4, v5, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_0
.end method

.method public responseMtlr(ZI)Z
    .locals 5
    .parameter "allowedOrNot"
    .parameter "reqID"

    .prologue
    .line 158
    :try_start_0
    invoke-direct {p0}, Lcom/android/server/LocationProxyService;->checkMtlrPermission()V

    .line 159
    const/4 v1, 0x0

    .line 160
    .local v1, responseType:I
    if-eqz p1, :cond_0

    .line 161
    const/4 v1, 0x1

    .line 166
    :goto_0
    iget-object v3, p0, Lcom/android/server/LocationProxyService;->mSuplCommands:Lcom/motorola/android/locationproxy/ISuplCommands;

    invoke-interface {v3, p2, v1}, Lcom/motorola/android/locationproxy/ISuplCommands;->sendLocationRequestResponse(II)V
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    .line 173
    const/4 v3, 0x1

    .end local v1           #responseType:I
    :goto_1
    return v3

    .line 164
    .restart local v1       #responseType:I
    :cond_0
    const/4 v1, 0x0

    goto :goto_0

    .line 167
    .end local v1           #responseType:I
    :catch_0
    move-exception v3

    move-object v2, v3

    .line 168
    .local v2, se:Ljava/lang/SecurityException;
    throw v2

    .line 169
    .end local v2           #se:Ljava/lang/SecurityException;
    :catch_1
    move-exception v3

    move-object v0, v3

    .line 170
    .local v0, e:Ljava/lang/Exception;
    const-string v3, "LocationProxyService"

    const-string v4, "responseMtlr got exception:"

    invoke-static {v3, v4, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 171
    const/4 v3, 0x0

    goto :goto_1
.end method

.method public run()V
    .locals 6

    .prologue
    const/4 v5, 0x0

    .line 315
    const/16 v2, 0xa

    invoke-static {v2}, Landroid/os/Process;->setThreadPriority(I)V

    .line 316
    invoke-static {}, Landroid/os/Looper;->prepare()V

    .line 318
    new-instance v2, Lcom/android/server/LocationProxyService$ProxyWorkerHandler;

    invoke-direct {v2, p0, v5}, Lcom/android/server/LocationProxyService$ProxyWorkerHandler;-><init>(Lcom/android/server/LocationProxyService;Lcom/android/server/LocationProxyService$1;)V

    iput-object v2, p0, Lcom/android/server/LocationProxyService;->mProxyHandler:Lcom/android/server/LocationProxyService$ProxyWorkerHandler;

    .line 321
    new-instance v2, Lcom/motorola/android/locationproxy/Supl;

    iget-object v3, p0, Lcom/android/server/LocationProxyService;->mContext:Landroid/content/Context;

    invoke-direct {v2, v3}, Lcom/motorola/android/locationproxy/Supl;-><init>(Landroid/content/Context;)V

    iput-object v2, p0, Lcom/android/server/LocationProxyService;->mSuplCommands:Lcom/motorola/android/locationproxy/ISuplCommands;

    .line 324
    new-instance v2, Lcom/motorola/android/locationproxy/SuplDataService;

    iget-object v3, p0, Lcom/android/server/LocationProxyService;->mSuplCommands:Lcom/motorola/android/locationproxy/ISuplCommands;

    invoke-direct {v2, v3}, Lcom/motorola/android/locationproxy/SuplDataService;-><init>(Lcom/motorola/android/locationproxy/ISuplCommands;)V

    iput-object v2, p0, Lcom/android/server/LocationProxyService;->mSuplDataService:Lcom/motorola/android/locationproxy/SuplDataService;

    .line 327
    new-instance v2, Lcom/motorola/android/locationproxy/SuplWapPushReceiver;

    iget-object v3, p0, Lcom/android/server/LocationProxyService;->mSuplCommands:Lcom/motorola/android/locationproxy/ISuplCommands;

    invoke-direct {v2, v3}, Lcom/motorola/android/locationproxy/SuplWapPushReceiver;-><init>(Lcom/motorola/android/locationproxy/ISuplCommands;)V

    iput-object v2, p0, Lcom/android/server/LocationProxyService;->mWapPushReceiver:Lcom/motorola/android/locationproxy/SuplWapPushReceiver;

    .line 329
    new-instance v1, Landroid/content/IntentFilter;

    invoke-direct {v1}, Landroid/content/IntentFilter;-><init>()V

    .line 330
    .local v1, f:Landroid/content/IntentFilter;
    const-string v2, "android.provider.Telephony.WAP_PUSH_RECEIVED"

    invoke-virtual {v1, v2}, Landroid/content/IntentFilter;->addAction(Ljava/lang/String;)V

    .line 332
    :try_start_0
    const-string v2, "application/vnd.omaloc-supl-init"

    invoke-virtual {v1, v2}, Landroid/content/IntentFilter;->addDataType(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 338
    :goto_0
    iget-object v2, p0, Lcom/android/server/LocationProxyService;->mContext:Landroid/content/Context;

    iget-object v3, p0, Lcom/android/server/LocationProxyService;->mWapPushReceiver:Lcom/motorola/android/locationproxy/SuplWapPushReceiver;

    invoke-virtual {v2, v3, v1, v5, v5}, Landroid/content/Context;->registerReceiver(Landroid/content/BroadcastReceiver;Landroid/content/IntentFilter;Ljava/lang/String;Landroid/os/Handler;)Landroid/content/Intent;

    .line 340
    iget-object v2, p0, Lcom/android/server/LocationProxyService;->mSuplCommands:Lcom/motorola/android/locationproxy/ISuplCommands;

    iget-object v3, p0, Lcom/android/server/LocationProxyService;->mProxyHandler:Lcom/android/server/LocationProxyService$ProxyWorkerHandler;

    const/16 v4, 0x10

    invoke-interface {v2, v3, v4, v5}, Lcom/motorola/android/locationproxy/ISuplCommands;->registerForSuplRequest(Landroid/os/Handler;ILjava/lang/Object;)V

    .line 341
    iget-object v2, p0, Lcom/android/server/LocationProxyService;->mSuplCommands:Lcom/motorola/android/locationproxy/ISuplCommands;

    iget-object v3, p0, Lcom/android/server/LocationProxyService;->mProxyHandler:Lcom/android/server/LocationProxyService$ProxyWorkerHandler;

    const/16 v4, 0x20

    invoke-interface {v2, v3, v4, v5}, Lcom/motorola/android/locationproxy/ISuplCommands;->registerForSuplRequest(Landroid/os/Handler;ILjava/lang/Object;)V

    .line 342
    iget-object v2, p0, Lcom/android/server/LocationProxyService;->mSuplCommands:Lcom/motorola/android/locationproxy/ISuplCommands;

    iget-object v3, p0, Lcom/android/server/LocationProxyService;->mProxyHandler:Lcom/android/server/LocationProxyService$ProxyWorkerHandler;

    const/16 v4, 0x40

    invoke-interface {v2, v3, v4, v5}, Lcom/motorola/android/locationproxy/ISuplCommands;->registerForSuplRequest(Landroid/os/Handler;ILjava/lang/Object;)V

    .line 344
    invoke-static {}, Landroid/os/Looper;->loop()V

    .line 345
    return-void

    .line 333
    :catch_0
    move-exception v2

    move-object v0, v2

    .line 335
    .local v0, e:Ljava/lang/Exception;
    const-string v2, "LocationProxyService"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Exception found: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method

.method public setSuplServer(Ljava/lang/String;)Z
    .locals 6
    .parameter "suplServer"

    .prologue
    const-string v5, "LocationProxyService"

    .line 126
    const-string v3, "LocationProxyService"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Enter setSuplServer():"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v5, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 127
    const/4 v1, 0x0

    .line 129
    .local v1, ret:Z
    :try_start_0
    invoke-direct {p0}, Lcom/android/server/LocationProxyService;->checkPermission()V

    .line 130
    iget-object v3, p0, Lcom/android/server/LocationProxyService;->mSuplCommands:Lcom/motorola/android/locationproxy/ISuplCommands;

    invoke-interface {v3, p1}, Lcom/motorola/android/locationproxy/ISuplCommands;->setUserConfigFQDN(Ljava/lang/String;)Z
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_1

    move-result v1

    .line 137
    :goto_0
    const-string v3, "LocationProxyService"

    const-string v3, "OK: Leave setSuplServer()"

    invoke-static {v5, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 138
    return v1

    .line 131
    :catch_0
    move-exception v3

    move-object v2, v3

    .line 132
    .local v2, se:Ljava/lang/SecurityException;
    throw v2

    .line 133
    .end local v2           #se:Ljava/lang/SecurityException;
    :catch_1
    move-exception v3

    move-object v0, v3

    .line 134
    .local v0, e:Ljava/lang/Exception;
    const-string v3, "LocationProxyService"

    const-string v3, "setSuplServer got Exception"

    invoke-static {v5, v3, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_0
.end method

.method public unregisterMtlrListener()Z
    .locals 2

    .prologue
    .line 189
    :try_start_0
    invoke-direct {p0}, Lcom/android/server/LocationProxyService;->checkMtlrPermission()V

    .line 190
    const/4 v1, 0x0

    iput-object v1, p0, Lcom/android/server/LocationProxyService;->mListener:Lcom/motorola/android/locationproxy/IMtlrListener;
    :try_end_0
    .catch Ljava/lang/SecurityException; {:try_start_0 .. :try_end_0} :catch_0

    .line 195
    const/4 v1, 0x1

    return v1

    .line 192
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 193
    .local v0, se:Ljava/lang/SecurityException;
    throw v0
.end method
