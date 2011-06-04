.class public final Lcom/motorola/android/locationproxy/Supl;
.super Lcom/motorola/android/locationproxy/BaseSuplCommands;
.source "Supl.java"

# interfaces
.implements Lcom/motorola/android/locationproxy/ISuplCommands;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/motorola/android/locationproxy/Supl$SuplReceiver;
    }
.end annotation


# static fields
.field static final LOG_TAG:Ljava/lang/String; = "SUPLJ"

.field static final MAX_COMMAND_BYTES:I = 0xfffd

.field static final SOCKET_NAME_SUPLD:Ljava/lang/String; = "location_shim"

.field static final SOCKET_OPEN_RETRY_MILLIS:I = 0xfa0

.field static final SUPL_LOG:Z = true

.field private static sFqdnReadLock:Ljava/lang/Object;

.field private static sFqdnWriteLock:Ljava/lang/Object;

.field private static sNextSessionId:B

.field private static sNextTransactionId:B

.field private static sSessionIdMonitor:Ljava/lang/Object;

.field private static sTransactionIdMonitor:Ljava/lang/Object;


# instance fields
.field private mFqdnAddr:Ljava/lang/String;

.field private mFqdnWriteResult:Z

.field mReceiver:Lcom/motorola/android/locationproxy/Supl$SuplReceiver;

.field mReceiverThread:Ljava/lang/Thread;

.field mRequestsList:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList",
            "<",
            "Lcom/motorola/android/locationproxy/SuplRequest;",
            ">;"
        }
    .end annotation
.end field

.field mSocket:Landroid/net/LocalSocket;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 215
    const/4 v0, 0x2

    sput-byte v0, Lcom/motorola/android/locationproxy/Supl;->sNextSessionId:B

    .line 216
    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    sput-object v0, Lcom/motorola/android/locationproxy/Supl;->sSessionIdMonitor:Ljava/lang/Object;

    .line 217
    const/4 v0, 0x1

    sput-byte v0, Lcom/motorola/android/locationproxy/Supl;->sNextTransactionId:B

    .line 218
    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    sput-object v0, Lcom/motorola/android/locationproxy/Supl;->sTransactionIdMonitor:Ljava/lang/Object;

    .line 220
    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    sput-object v0, Lcom/motorola/android/locationproxy/Supl;->sFqdnReadLock:Ljava/lang/Object;

    .line 221
    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    sput-object v0, Lcom/motorola/android/locationproxy/Supl;->sFqdnWriteLock:Ljava/lang/Object;

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;)V
    .locals 3
    .parameter "context"

    .prologue
    .line 422
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/BaseSuplCommands;-><init>(Landroid/content/Context;)V

    .line 222
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnAddr:Ljava/lang/String;

    .line 223
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnWriteResult:Z

    .line 229
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    .line 424
    new-instance v0, Lcom/motorola/android/locationproxy/Supl$SuplReceiver;

    invoke-direct {v0, p0}, Lcom/motorola/android/locationproxy/Supl$SuplReceiver;-><init>(Lcom/motorola/android/locationproxy/Supl;)V

    iput-object v0, p0, Lcom/motorola/android/locationproxy/Supl;->mReceiver:Lcom/motorola/android/locationproxy/Supl$SuplReceiver;

    .line 425
    new-instance v0, Ljava/lang/Thread;

    iget-object v1, p0, Lcom/motorola/android/locationproxy/Supl;->mReceiver:Lcom/motorola/android/locationproxy/Supl$SuplReceiver;

    const-string v2, "SuplReceiver"

    invoke-direct {v0, v1, v2}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;Ljava/lang/String;)V

    iput-object v0, p0, Lcom/motorola/android/locationproxy/Supl;->mReceiverThread:Ljava/lang/Thread;

    .line 426
    iget-object v0, p0, Lcom/motorola/android/locationproxy/Supl;->mReceiverThread:Ljava/lang/Thread;

    invoke-virtual {v0}, Ljava/lang/Thread;->start()V

    .line 427
    return-void
.end method

.method static SubCommandIdToString(B)Ljava/lang/String;
    .locals 1
    .parameter "subCommandId"

    .prologue
    .line 1452
    packed-switch p0, :pswitch_data_0

    .line 1471
    :pswitch_0
    const-string v0, "<unknown subCommandId>"

    :goto_0
    return-object v0

    .line 1453
    :pswitch_1
    const-string v0, "WRITE_DB_REQ"

    goto :goto_0

    .line 1454
    :pswitch_2
    const-string v0, "WRITE_DB_RES"

    goto :goto_0

    .line 1455
    :pswitch_3
    const-string v0, "READ_DB_REQ"

    goto :goto_0

    .line 1456
    :pswitch_4
    const-string v0, "READ_DB_RES"

    goto :goto_0

    .line 1457
    :pswitch_5
    const-string v0, "OPEN_SOCK_REQ"

    goto :goto_0

    .line 1458
    :pswitch_6
    const-string v0, "OPEN_SOCK_RES"

    goto :goto_0

    .line 1459
    :pswitch_7
    const-string v0, "SOCK_DATA_REQ"

    goto :goto_0

    .line 1460
    :pswitch_8
    const-string v0, "SOCK_DATA_RES"

    goto :goto_0

    .line 1461
    :pswitch_9
    const-string v0, "SOCK_DATA_IND"

    goto :goto_0

    .line 1462
    :pswitch_a
    const-string v0, "CLOSE_SOCK_REQ"

    goto :goto_0

    .line 1463
    :pswitch_b
    const-string v0, "CLOSE_SOCK_RES"

    goto :goto_0

    .line 1464
    :pswitch_c
    const-string v0, "WAP_PUSH_IND"

    goto :goto_0

    .line 1465
    :pswitch_d
    const-string v0, "MTLR_NOTIFY_IND"

    goto :goto_0

    .line 1466
    :pswitch_e
    const-string v0, "MTLR_NOTIFY_RES"

    goto :goto_0

    .line 1467
    :pswitch_f
    const-string v0, "MTLR_NOTIFY_STATUS"

    goto :goto_0

    .line 1468
    :pswitch_10
    const-string v0, "TLS_REQ"

    goto :goto_0

    .line 1469
    :pswitch_11
    const-string v0, "TLS_RES"

    goto :goto_0

    .line 1470
    :pswitch_12
    const-string v0, "MTLR2_IND"

    goto :goto_0

    .line 1452
    :pswitch_data_0
    .packed-switch 0x4
        :pswitch_1
        :pswitch_2
        :pswitch_3
        :pswitch_4
        :pswitch_0
        :pswitch_5
        :pswitch_6
        :pswitch_7
        :pswitch_8
        :pswitch_9
        :pswitch_a
        :pswitch_b
        :pswitch_c
        :pswitch_0
        :pswitch_0
        :pswitch_d
        :pswitch_e
        :pswitch_f
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_10
        :pswitch_11
        :pswitch_12
    .end packed-switch
.end method

.method static synthetic access$000(Ljava/io/InputStream;[B)I
    .locals 1
    .parameter "x0"
    .parameter "x1"
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 206
    invoke-static {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->readSuplMessage(Ljava/io/InputStream;[B)I

    move-result v0

    return v0
.end method

.method static synthetic access$100([BI)V
    .locals 0
    .parameter "x0"
    .parameter "x1"

    .prologue
    .line 206
    invoke-static {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->logHexData([BI)V

    return-void
.end method

.method static synthetic access$200(Lcom/motorola/android/locationproxy/Supl;Landroid/os/Parcel;)V
    .locals 0
    .parameter "x0"
    .parameter "x1"

    .prologue
    .line 206
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->processResponse(Landroid/os/Parcel;)V

    return-void
.end method

.method private convertUcs2ToUtf8([B)[B
    .locals 8
    .parameter "data"

    .prologue
    const/4 v7, 0x0

    .line 1299
    const/4 v2, 0x0

    .line 1301
    .local v2, l:I
    const/16 v6, 0xd8

    new-array v0, v6, [B

    .line 1302
    .local v0, buf:[B
    const/4 v1, 0x0

    .local v1, i:I
    :goto_0
    array-length v6, p1

    if-ge v1, v6, :cond_2

    .line 1303
    aget-byte v6, p1, v1

    and-int/lit16 v6, v6, 0xff

    int-to-char v5, v6

    .line 1304
    .local v5, v:C
    shl-int/lit8 v6, v5, 0x8

    int-to-char v5, v6

    .line 1305
    add-int/lit8 v6, v1, 0x1

    aget-byte v6, p1, v6

    and-int/lit16 v6, v6, 0xff

    or-int/2addr v6, v5

    int-to-char v5, v6

    .line 1306
    const/16 v6, 0x80

    if-ge v5, v6, :cond_0

    .line 1307
    add-int/lit8 v3, v2, 0x1

    .end local v2           #l:I
    .local v3, l:I
    and-int/lit8 v6, v5, 0x7f

    int-to-byte v6, v6

    aput-byte v6, v0, v2

    move v2, v3

    .line 1302
    .end local v3           #l:I
    .restart local v2       #l:I
    :goto_1
    add-int/lit8 v1, v1, 0x2

    goto :goto_0

    .line 1309
    :cond_0
    const/16 v6, 0x800

    if-ge v5, v6, :cond_1

    .line 1310
    add-int/lit8 v3, v2, 0x1

    .end local v2           #l:I
    .restart local v3       #l:I
    and-int/lit16 v6, v5, 0x7c0

    or-int/lit16 v6, v6, 0x3000

    shr-int/lit8 v6, v6, 0x6

    and-int/lit16 v6, v6, 0xff

    int-to-byte v6, v6

    aput-byte v6, v0, v2

    .line 1311
    add-int/lit8 v2, v3, 0x1

    .end local v3           #l:I
    .restart local v2       #l:I
    and-int/lit8 v6, v5, 0x3f

    or-int/lit16 v6, v6, 0x80

    and-int/lit16 v6, v6, 0xff

    int-to-byte v6, v6

    aput-byte v6, v0, v3

    goto :goto_1

    .line 1314
    :cond_1
    add-int/lit8 v3, v2, 0x1

    .end local v2           #l:I
    .restart local v3       #l:I
    const v6, 0xf000

    and-int/2addr v6, v5

    shr-int/lit8 v6, v6, 0xc

    or-int/lit16 v6, v6, 0xe0

    and-int/lit16 v6, v6, 0xff

    int-to-byte v6, v6

    aput-byte v6, v0, v2

    .line 1315
    add-int/lit8 v2, v3, 0x1

    .end local v3           #l:I
    .restart local v2       #l:I
    and-int/lit16 v6, v5, 0xfc0

    or-int/lit16 v6, v6, 0x2000

    shr-int/lit8 v6, v6, 0x6

    and-int/lit16 v6, v6, 0xff

    int-to-byte v6, v6

    aput-byte v6, v0, v3

    .line 1316
    add-int/lit8 v3, v2, 0x1

    .end local v2           #l:I
    .restart local v3       #l:I
    and-int/lit8 v6, v5, 0x3f

    or-int/lit16 v6, v6, 0x80

    and-int/lit16 v6, v6, 0xff

    int-to-byte v6, v6

    aput-byte v6, v0, v2

    move v2, v3

    .end local v3           #l:I
    .restart local v2       #l:I
    goto :goto_1

    .line 1320
    .end local v5           #v:C
    :cond_2
    new-array v4, v2, [B

    .line 1321
    .local v4, utf8String:[B
    invoke-static {v0, v7, v4, v7, v2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 1322
    invoke-static {v4}, Lcom/motorola/android/locationproxy/Supl;->logHexData([B)V

    .line 1323
    return-object v4
.end method

.method private findAndRemoveRequestFromList(BBB)Lcom/motorola/android/locationproxy/SuplRequest;
    .locals 7
    .parameter "sessionId"
    .parameter "transactionId"
    .parameter "subCmdId"

    .prologue
    const-string v6, " tID="

    const-string v5, " cmd="

    .line 915
    iget-object v3, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    monitor-enter v3

    .line 916
    const/4 v0, 0x0

    .local v0, i:I
    :try_start_0
    iget-object v4, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v4}, Ljava/util/ArrayList;->size()I

    move-result v2

    .local v2, s:I
    :goto_0
    if-ge v0, v2, :cond_1

    .line 917
    iget-object v4, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v4, v0}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/motorola/android/locationproxy/SuplRequest;

    .line 918
    .local v1, r:Lcom/motorola/android/locationproxy/SuplRequest;
    iget-byte v4, v1, Lcom/motorola/android/locationproxy/SuplRequest;->mSessionId:B

    if-ne v4, p1, :cond_0

    iget-byte v4, v1, Lcom/motorola/android/locationproxy/SuplRequest;->mTransactionId:B

    if-ne v4, p2, :cond_0

    iget-byte v4, v1, Lcom/motorola/android/locationproxy/SuplRequest;->mSubCommandId:B

    if-ne v4, p3, :cond_0

    .line 921
    iget-object v4, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v4, v0}, Ljava/util/ArrayList;->remove(I)Ljava/lang/Object;

    .line 922
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "findAndRemoveRequestFromList: Found REQUEST: sID="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, " tID="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, " cmd="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-static {p3}, Lcom/motorola/android/locationproxy/Supl;->SubCommandIdToString(B)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-direct {p0, v4}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 925
    monitor-exit v3

    move-object v3, v1

    .line 933
    .end local v1           #r:Lcom/motorola/android/locationproxy/SuplRequest;
    :goto_1
    return-object v3

    .line 916
    .restart local v1       #r:Lcom/motorola/android/locationproxy/SuplRequest;
    :cond_0
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 928
    .end local v1           #r:Lcom/motorola/android/locationproxy/SuplRequest;
    :cond_1
    monitor-exit v3
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 930
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "findAndRemoveRequestFromList: NOT Found REQUEST: sID="

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, " tID="

    invoke-virtual {v3, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, " cmd="

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-static {p3}, Lcom/motorola/android/locationproxy/Supl;->SubCommandIdToString(B)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {p0, v3}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 933
    const/4 v3, 0x0

    goto :goto_1

    .line 928
    .end local v2           #s:I
    :catchall_0
    move-exception v4

    :try_start_1
    monitor-exit v3
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v4
.end method

.method private findAndRemoveRequestFromList(I)Lcom/motorola/android/locationproxy/SuplRequest;
    .locals 6
    .parameter "serial"

    .prologue
    .line 899
    iget-object v3, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    monitor-enter v3

    .line 900
    const/4 v0, 0x0

    .local v0, i:I
    :try_start_0
    iget-object v4, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v4}, Ljava/util/ArrayList;->size()I

    move-result v2

    .local v2, s:I
    :goto_0
    if-ge v0, v2, :cond_1

    .line 901
    iget-object v4, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v4, v0}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/motorola/android/locationproxy/SuplRequest;

    .line 902
    .local v1, r:Lcom/motorola/android/locationproxy/SuplRequest;
    iget v4, v1, Lcom/motorola/android/locationproxy/SuplRequest;->mSerial:I

    if-ne v4, p1, :cond_0

    .line 903
    iget-object v4, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v4, v0}, Ljava/util/ArrayList;->remove(I)Ljava/lang/Object;

    .line 904
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "findAndRemoveRequestFromList: Found REQUEST: id="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-direct {p0, v4}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 905
    monitor-exit v3

    move-object v3, v1

    .line 910
    .end local v1           #r:Lcom/motorola/android/locationproxy/SuplRequest;
    :goto_1
    return-object v3

    .line 900
    .restart local v1       #r:Lcom/motorola/android/locationproxy/SuplRequest;
    :cond_0
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 908
    .end local v1           #r:Lcom/motorola/android/locationproxy/SuplRequest;
    :cond_1
    monitor-exit v3
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 909
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "findAndRemoveRequestFromList: NOT Found REQUEST id="

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {p0, v3}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 910
    const/4 v3, 0x0

    goto :goto_1

    .line 908
    .end local v2           #s:I
    :catchall_0
    move-exception v4

    :try_start_1
    monitor-exit v3
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v4
.end method

.method private generateSessionID()B
    .locals 3

    .prologue
    .line 1481
    const/4 v0, 0x0

    .line 1482
    .local v0, ret:B
    sget-object v1, Lcom/motorola/android/locationproxy/Supl;->sSessionIdMonitor:Ljava/lang/Object;

    monitor-enter v1

    .line 1483
    :try_start_0
    sget-byte v0, Lcom/motorola/android/locationproxy/Supl;->sNextSessionId:B

    .line 1484
    sget-byte v2, Lcom/motorola/android/locationproxy/Supl;->sNextSessionId:B

    add-int/lit8 v2, v2, 0x1

    int-to-byte v2, v2

    sput-byte v2, Lcom/motorola/android/locationproxy/Supl;->sNextSessionId:B

    .line 1485
    monitor-exit v1

    .line 1486
    return v0

    .line 1485
    :catchall_0
    move-exception v2

    monitor-exit v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v2
.end method

.method private generateTransactionId()B
    .locals 3

    .prologue
    .line 1491
    const/4 v0, 0x0

    .line 1492
    .local v0, ret:B
    sget-object v1, Lcom/motorola/android/locationproxy/Supl;->sTransactionIdMonitor:Ljava/lang/Object;

    monitor-enter v1

    .line 1493
    :try_start_0
    sget-byte v0, Lcom/motorola/android/locationproxy/Supl;->sNextTransactionId:B

    .line 1494
    sget-byte v2, Lcom/motorola/android/locationproxy/Supl;->sNextTransactionId:B

    add-int/lit8 v2, v2, 0x1

    int-to-byte v2, v2

    sput-byte v2, Lcom/motorola/android/locationproxy/Supl;->sNextTransactionId:B

    .line 1495
    monitor-exit v1

    .line 1496
    return v0

    .line 1495
    :catchall_0
    move-exception v2

    monitor-exit v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v2
.end method

.method private static logHexData([B)V
    .locals 1
    .parameter "data"

    .prologue
    .line 1540
    array-length v0, p0

    invoke-static {p0, v0}, Lcom/motorola/android/locationproxy/Supl;->logHexData([BI)V

    .line 1541
    return-void
.end method

.method private static logHexData([BI)V
    .locals 9
    .parameter "data"
    .parameter "length"

    .prologue
    const-string v8, "]"

    const-string v7, "[ "

    const-string v6, "SUPLJ"

    .line 1513
    array-length v4, p0

    if-ge p1, v4, :cond_1

    move v1, p1

    .line 1515
    .local v1, l:I
    :goto_0
    const-string v4, "SUPLJ"

    const-string v4, "package: "

    invoke-static {v6, v4}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 1517
    new-instance v2, Ljava/lang/StringBuilder;

    const-string v4, "[ "

    invoke-direct {v2, v7}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 1518
    .local v2, sb:Ljava/lang/StringBuilder;
    const/4 v0, 0x0

    .local v0, i:I
    :goto_1
    if-ge v0, v1, :cond_3

    .line 1519
    rem-int/lit8 v4, v0, 0x8

    if-nez v4, :cond_0

    if-lez v0, :cond_0

    .line 1520
    const-string v4, "]"

    invoke-virtual {v2, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 1521
    const-string v4, "SUPLJ"

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v6, v4}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 1522
    new-instance v2, Ljava/lang/StringBuilder;

    .end local v2           #sb:Ljava/lang/StringBuilder;
    const-string v4, "[ "

    invoke-direct {v2, v7}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 1525
    .restart local v2       #sb:Ljava/lang/StringBuilder;
    :cond_0
    aget-byte v3, p0, v0

    .line 1526
    .local v3, v:I
    and-int/lit16 v3, v3, 0xff

    .line 1527
    const/16 v4, 0x10

    if-ge v3, v4, :cond_2

    .line 1528
    const-string v4, "0x0"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 1532
    :goto_2
    invoke-static {v3}, Ljava/lang/Integer;->toHexString(I)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, " "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 1518
    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    .line 1513
    .end local v0           #i:I
    .end local v1           #l:I
    .end local v2           #sb:Ljava/lang/StringBuilder;
    .end local v3           #v:I
    :cond_1
    array-length v4, p0

    move v1, v4

    goto :goto_0

    .line 1530
    .restart local v0       #i:I
    .restart local v1       #l:I
    .restart local v2       #sb:Ljava/lang/StringBuilder;
    .restart local v3       #v:I
    :cond_2
    const-string v4, "0x"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    goto :goto_2

    .line 1534
    .end local v3           #v:I
    :cond_3
    const-string v4, "]"

    invoke-virtual {v2, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 1535
    const-string v4, "SUPLJ"

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v6, v4}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 1536
    return-void
.end method

.method private logSuplApBpRequest([B)V
    .locals 6
    .parameter "msg"

    .prologue
    const-string v5, "SUPLJ"

    .line 1501
    const/4 v3, 0x3

    invoke-direct {p0, p1, v3}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v1

    .line 1502
    .local v1, subCommandId:B
    const/4 v3, 0x4

    invoke-direct {p0, p1, v3}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v0

    .line 1503
    .local v0, sessionId:B
    const/4 v3, 0x5

    invoke-direct {p0, p1, v3}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v2

    .line 1505
    .local v2, transactionId:B
    const-string v3, "SUPLJ"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Request:"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-static {v1}, Lcom/motorola/android/locationproxy/Supl;->SubCommandIdToString(B)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v5, v3}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 1506
    const-string v3, "SUPLJ"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Session ["

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, "], transaction ["

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, "]"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v5, v3}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 1507
    invoke-static {p1}, Lcom/motorola/android/locationproxy/Supl;->logHexData([B)V

    .line 1508
    return-void
.end method

.method private processCloseSocketRequest(Landroid/os/Parcel;)V
    .locals 9
    .parameter "p"

    .prologue
    const/4 v8, 0x0

    .line 1147
    invoke-virtual {p1}, Landroid/os/Parcel;->marshall()[B

    move-result-object v0

    .line 1148
    .local v0, buf:[B
    const/4 v1, 0x1

    .line 1149
    .local v1, offset:I
    invoke-direct {p0, v0, v1}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v4

    .line 1150
    .local v4, sessionId:B
    add-int/lit8 v1, v1, 0x1

    .line 1151
    invoke-direct {p0, v0, v1}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v5

    .line 1152
    .local v5, transactionId:B
    add-int/lit8 v1, v1, 0x1

    .line 1154
    const/16 v6, 0xe

    invoke-static {v6, v4, v5, v8}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v2

    .line 1158
    .local v2, r:Lcom/motorola/android/locationproxy/SuplRequest;
    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->serialString()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "> "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    iget-byte v7, v2, Lcom/motorola/android/locationproxy/SuplRequest;->mSubCommandId:B

    invoke-static {v7}, Lcom/motorola/android/locationproxy/Supl;->SubCommandIdToString(B)Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-direct {p0, v6}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 1159
    iget-object v6, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    monitor-enter v6

    .line 1160
    :try_start_0
    iget-object v7, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v7, v2}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 1161
    monitor-exit v6
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 1163
    const/4 v6, 0x2

    new-array v3, v6, [Ljava/lang/Object;

    .line 1164
    .local v3, result:[Ljava/lang/Object;
    const/4 v6, 0x0

    iget v7, v2, Lcom/motorola/android/locationproxy/SuplRequest;->mSerial:I

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    aput-object v7, v3, v6

    .line 1167
    const/4 v6, 0x1

    invoke-direct {p0, v0, v1}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v7

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    aput-object v7, v3, v6

    .line 1168
    add-int/lit8 v1, v1, 0x4

    .line 1170
    iget-object v6, p0, Lcom/motorola/android/locationproxy/Supl;->mCloseSocketRegistrants:Landroid/os/RegistrantList;

    new-instance v7, Landroid/os/AsyncResult;

    invoke-direct {v7, v8, v3, v8}, Landroid/os/AsyncResult;-><init>(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Throwable;)V

    invoke-virtual {v6, v7}, Landroid/os/RegistrantList;->notifyRegistrants(Landroid/os/AsyncResult;)V

    .line 1171
    return-void

    .line 1161
    .end local v3           #result:[Ljava/lang/Object;
    :catchall_0
    move-exception v7

    :try_start_1
    monitor-exit v6
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v7
.end method

.method private processDbReadResult(Landroid/os/Parcel;)V
    .locals 15
    .parameter "p"

    .prologue
    .line 1011
    invoke-virtual/range {p1 .. p1}, Landroid/os/Parcel;->marshall()[B

    move-result-object v0

    .line 1012
    .local v0, buf:[B
    const/4 v6, 0x1

    .line 1013
    .local v6, offset:I
    invoke-direct {p0, v0, v6}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v9

    .line 1014
    .local v9, sessionId:B
    add-int/lit8 v6, v6, 0x1

    .line 1015
    invoke-direct {p0, v0, v6}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v11

    .line 1016
    .local v11, transactionId:B
    add-int/lit8 v6, v6, 0x1

    .line 1018
    const/4 v12, 0x6

    invoke-direct {p0, v9, v11, v12}, Lcom/motorola/android/locationproxy/Supl;->findAndRemoveRequestFromList(BBB)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v7

    .line 1021
    .local v7, r:Lcom/motorola/android/locationproxy/SuplRequest;
    if-nez v7, :cond_2

    .line 1022
    const-string v12, "SUPLJ"

    new-instance v13, Ljava/lang/StringBuilder;

    invoke-direct {v13}, Ljava/lang/StringBuilder;-><init>()V

    const-string v14, "Unexpected DB write result! sessiionId: "

    invoke-virtual {v13, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    invoke-virtual {v13, v9}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v13

    const-string v14, "transactionId: "

    invoke-virtual {v13, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    invoke-virtual {v13, v11}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v13

    invoke-virtual {v13}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v13

    invoke-static {v12, v13}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 1024
    const/4 v12, 0x0

    iput-object v12, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnAddr:Ljava/lang/String;

    .line 1054
    :cond_0
    :goto_0
    sget-object v12, Lcom/motorola/android/locationproxy/Supl;->sFqdnReadLock:Ljava/lang/Object;

    monitor-enter v12

    .line 1055
    :try_start_0
    const-string v13, "SUPLJ"

    const-string v14, "calling sFqdnReadLock.notifyAll()"

    invoke-static {v13, v14}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 1056
    sget-object v13, Lcom/motorola/android/locationproxy/Supl;->sFqdnReadLock:Ljava/lang/Object;

    invoke-virtual {v13}, Ljava/lang/Object;->notifyAll()V

    .line 1057
    monitor-exit v12
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 1059
    if-eqz v7, :cond_1

    .line 1060
    invoke-virtual {v7}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 1062
    :cond_1
    return-void

    .line 1028
    :cond_2
    :try_start_1
    invoke-direct {p0, v0, v6}, Lcom/motorola/android/locationproxy/Supl;->readShort([BI)S

    move-result v5

    .line 1029
    .local v5, numFiles:S
    add-int/lit8 v6, v6, 0x2

    .line 1030
    const-string v12, "SUPLJ"

    new-instance v13, Ljava/lang/StringBuilder;

    invoke-direct {v13}, Ljava/lang/StringBuilder;-><init>()V

    const-string v14, "Number of files: "

    invoke-virtual {v13, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    invoke-virtual {v13, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v13

    invoke-virtual {v13}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v13

    invoke-static {v12, v13}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 1032
    const/4 v3, 0x0

    .local v3, i:S
    :goto_1
    if-ge v3, v5, :cond_3

    .line 1033
    invoke-direct {p0, v0, v6}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v2

    .line 1034
    .local v2, fileId:I
    add-int/lit8 v6, v6, 0x4

    .line 1035
    invoke-direct {p0, v0, v6}, Lcom/motorola/android/locationproxy/Supl;->readShort([BI)S

    move-result v4

    .line 1036
    .local v4, length:S
    add-int/lit8 v6, v6, 0x2

    .line 1039
    invoke-direct {p0, v0, v6, v4}, Lcom/motorola/android/locationproxy/Supl;->readByteArray([BII)[B

    move-result-object v1

    .line 1040
    .local v1, data:[B
    add-int/2addr v6, v4

    .line 1042
    new-instance v12, Ljava/lang/String;

    invoke-direct {v12, v1}, Ljava/lang/String;-><init>([B)V

    iput-object v12, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnAddr:Ljava/lang/String;

    .line 1043
    const-string v12, "SUPLJ"

    new-instance v13, Ljava/lang/StringBuilder;

    invoke-direct {v13}, Ljava/lang/StringBuilder;-><init>()V

    const-string v14, "read supl address:"

    invoke-virtual {v13, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    iget-object v14, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnAddr:Ljava/lang/String;

    invoke-virtual {v13, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    invoke-virtual {v13}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v13

    invoke-static {v12, v13}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 1032
    add-int/lit8 v12, v3, 0x1

    int-to-short v3, v12

    goto :goto_1

    .line 1046
    .end local v1           #data:[B
    .end local v2           #fileId:I
    .end local v4           #length:S
    :cond_3
    invoke-direct {p0, v0, v6}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v8

    .line 1047
    .local v8, result:I
    if-eqz v8, :cond_0

    .line 1048
    new-instance v12, Ljava/lang/RuntimeException;

    const-string v13, "DB Error"

    invoke-direct {v12, v13}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v12
    :try_end_1
    .catch Ljava/lang/Throwable; {:try_start_1 .. :try_end_1} :catch_0

    .line 1050
    .end local v3           #i:S
    .end local v5           #numFiles:S
    .end local v8           #result:I
    :catch_0
    move-exception v12

    move-object v10, v12

    .line 1051
    .local v10, tr:Ljava/lang/Throwable;
    const/4 v12, 0x0

    iput-object v12, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnAddr:Ljava/lang/String;

    goto :goto_0

    .line 1057
    .end local v10           #tr:Ljava/lang/Throwable;
    :catchall_0
    move-exception v13

    :try_start_2
    monitor-exit v12
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    throw v13
.end method

.method private processDbWriteResult(Landroid/os/Parcel;)V
    .locals 11
    .parameter "p"

    .prologue
    const/4 v10, 0x0

    const-string v9, "SUPLJ"

    .line 968
    invoke-virtual {p1}, Landroid/os/Parcel;->marshall()[B

    move-result-object v0

    .line 969
    .local v0, buf:[B
    const/4 v1, 0x1

    .line 970
    .local v1, offset:I
    invoke-direct {p0, v0, v1}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v4

    .line 971
    .local v4, sessionId:B
    add-int/lit8 v1, v1, 0x1

    .line 972
    invoke-direct {p0, v0, v1}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v6

    .line 973
    .local v6, transactionId:B
    add-int/lit8 v1, v1, 0x1

    .line 975
    const/4 v7, 0x4

    invoke-direct {p0, v4, v6, v7}, Lcom/motorola/android/locationproxy/Supl;->findAndRemoveRequestFromList(BBB)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v2

    .line 978
    .local v2, r:Lcom/motorola/android/locationproxy/SuplRequest;
    if-nez v2, :cond_1

    .line 979
    const-string v7, "SUPLJ"

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "Unexpected DB write result! sessiionId: "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, " transactionId: "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v6}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v9, v7}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 981
    iput-boolean v10, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnWriteResult:Z

    .line 999
    :goto_0
    sget-object v7, Lcom/motorola/android/locationproxy/Supl;->sFqdnWriteLock:Ljava/lang/Object;

    monitor-enter v7

    .line 1000
    :try_start_0
    const-string v8, "SUPLJ"

    const-string v9, "calling sFqdnWriteLock.notifyAll()"

    invoke-static {v8, v9}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 1001
    sget-object v8, Lcom/motorola/android/locationproxy/Supl;->sFqdnWriteLock:Ljava/lang/Object;

    invoke-virtual {v8}, Ljava/lang/Object;->notifyAll()V

    .line 1002
    monitor-exit v7
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 1004
    if-eqz v2, :cond_0

    .line 1005
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 1007
    :cond_0
    return-void

    .line 985
    :cond_1
    :try_start_1
    invoke-direct {p0, v0, v1}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v3

    .line 986
    .local v3, result:I
    add-int/lit8 v1, v1, 0x4

    .line 988
    const-string v7, "SUPLJ"

    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    const-string v9, "result = "

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-static {v7, v8}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 989
    if-eqz v3, :cond_2

    .line 990
    const-string v7, "SUPLJ"

    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    const-string v9, "DB Error: "

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-static {v7, v8}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 991
    new-instance v7, Ljava/lang/RuntimeException;

    const-string v8, "DB Error"

    invoke-direct {v7, v8}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v7
    :try_end_1
    .catch Ljava/lang/Throwable; {:try_start_1 .. :try_end_1} :catch_0

    .line 994
    .end local v3           #result:I
    :catch_0
    move-exception v7

    move-object v5, v7

    .line 995
    .local v5, tr:Ljava/lang/Throwable;
    iput-boolean v10, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnWriteResult:Z

    goto :goto_0

    .line 993
    .end local v5           #tr:Ljava/lang/Throwable;
    .restart local v3       #result:I
    :cond_2
    const/4 v7, 0x1

    :try_start_2
    iput-boolean v7, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnWriteResult:Z
    :try_end_2
    .catch Ljava/lang/Throwable; {:try_start_2 .. :try_end_2} :catch_0

    goto :goto_0

    .line 1002
    .end local v3           #result:I
    :catchall_0
    move-exception v8

    :try_start_3
    monitor-exit v7
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    throw v8
.end method

.method private processMtlr2Request(Landroid/os/Parcel;)V
    .locals 24
    .parameter "p"

    .prologue
    .line 1328
    invoke-virtual/range {p1 .. p1}, Landroid/os/Parcel;->marshall()[B

    move-result-object v4

    .line 1329
    .local v4, buf:[B
    const/4 v13, 0x1

    .line 1330
    .local v13, offset:I
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v18

    .line 1331
    .local v18, sessionId:B
    add-int/lit8 v13, v13, 0x1

    .line 1332
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v19

    .line 1333
    .local v19, transactionId:B
    add-int/lit8 v13, v13, 0x1

    .line 1335
    const/16 v20, 0x1e

    const/16 v21, 0x0

    move/from16 v0, v20

    move/from16 v1, v18

    move/from16 v2, v19

    move-object/from16 v3, v21

    invoke-static {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v14

    .line 1339
    .local v14, r:Lcom/motorola/android/locationproxy/SuplRequest;
    new-instance v20, Ljava/lang/StringBuilder;

    invoke-direct/range {v20 .. v20}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v14}, Lcom/motorola/android/locationproxy/SuplRequest;->serialString()Ljava/lang/String;

    move-result-object v21

    invoke-virtual/range {v20 .. v21}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v20

    const-string v21, "> "

    invoke-virtual/range {v20 .. v21}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v20

    move-object v0, v14

    iget-byte v0, v0, Lcom/motorola/android/locationproxy/SuplRequest;->mSubCommandId:B

    move/from16 v21, v0

    invoke-static/range {v21 .. v21}, Lcom/motorola/android/locationproxy/Supl;->SubCommandIdToString(B)Ljava/lang/String;

    move-result-object v21

    invoke-virtual/range {v20 .. v21}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v20

    invoke-virtual/range {v20 .. v20}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v20

    move-object/from16 v0, p0

    move-object/from16 v1, v20

    invoke-direct {v0, v1}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 1340
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    move-object/from16 v20, v0

    monitor-enter v20

    .line 1341
    :try_start_0
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    move-object/from16 v21, v0

    move-object/from16 v0, v21

    move-object v1, v14

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 1342
    monitor-exit v20
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 1344
    const/16 v20, 0x8

    move/from16 v0, v20

    new-array v0, v0, [Ljava/lang/Object;

    move-object/from16 v17, v0

    .line 1345
    .local v17, result:[Ljava/lang/Object;
    const/16 v20, 0x0

    move-object v0, v14

    iget v0, v0, Lcom/motorola/android/locationproxy/SuplRequest;->mSerial:I

    move/from16 v21, v0

    invoke-static/range {v21 .. v21}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v21

    aput-object v21, v17, v20

    .line 1348
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v12

    .line 1349
    .local v12, notifyType:I
    const/16 v20, 0x1

    invoke-static {v12}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v21

    aput-object v21, v17, v20

    .line 1350
    add-int/lit8 v13, v13, 0x4

    .line 1353
    const/16 v20, 0x2

    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v21

    invoke-static/range {v21 .. v21}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v21

    aput-object v21, v17, v20

    .line 1354
    add-int/lit8 v13, v13, 0x4

    .line 1359
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v9

    .line 1360
    .local v9, codingSchema:B
    add-int/lit8 v13, v13, 0x1

    .line 1362
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v11

    .line 1363
    .local v11, length:B
    add-int/lit8 v13, v13, 0x1

    .line 1364
    new-instance v15, Ljava/lang/String;

    const-string v20, ""

    move-object v0, v15

    move-object/from16 v1, v20

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>(Ljava/lang/String;)V

    .line 1365
    .local v15, requestorId:Ljava/lang/String;
    if-lez v11, :cond_0

    .line 1367
    :try_start_1
    new-instance v16, Ljava/lang/String;

    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    move v3, v11

    invoke-direct {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/Supl;->readByteArray([BII)[B

    move-result-object v20

    move-object/from16 v0, p0

    move-object/from16 v1, v20

    invoke-direct {v0, v1}, Lcom/motorola/android/locationproxy/Supl;->convertUcs2ToUtf8([B)[B

    move-result-object v20

    const-string v21, "UTF8"

    move-object/from16 v0, v16

    move-object/from16 v1, v20

    move-object/from16 v2, v21

    invoke-direct {v0, v1, v2}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end_1
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_1 .. :try_end_1} :catch_0

    .end local v15           #requestorId:Ljava/lang/String;
    .local v16, requestorId:Ljava/lang/String;
    move-object/from16 v15, v16

    .line 1371
    .end local v16           #requestorId:Ljava/lang/String;
    .restart local v15       #requestorId:Ljava/lang/String;
    :goto_0
    add-int/lit8 v13, v11, 0xd

    .line 1373
    :cond_0
    const/16 v20, 0x3

    aput-object v15, v17, v20

    .line 1376
    const/16 v20, 0x4

    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v21

    invoke-static/range {v21 .. v21}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object v21

    aput-object v21, v17, v20

    .line 1377
    add-int/lit8 v13, v13, 0x1

    .line 1380
    new-instance v6, Ljava/lang/String;

    const-string v20, ""

    move-object v0, v6

    move-object/from16 v1, v20

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>(Ljava/lang/String;)V

    .line 1381
    .local v6, clientName:Ljava/lang/String;
    const/16 v20, 0xff

    move v0, v9

    move/from16 v1, v20

    if-eq v0, v1, :cond_1

    .line 1382
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v11

    .line 1383
    add-int/lit8 v13, v13, 0x1

    .line 1384
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    move v3, v11

    invoke-direct {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/Supl;->readByteArray([BII)[B

    move-result-object v8

    .line 1385
    .local v8, clientNameBuf:[B
    add-int/2addr v13, v11

    .line 1387
    :try_start_2
    new-instance v7, Ljava/lang/String;

    move-object/from16 v0, p0

    move-object v1, v8

    invoke-direct {v0, v1}, Lcom/motorola/android/locationproxy/Supl;->convertUcs2ToUtf8([B)[B

    move-result-object v20

    const-string v21, "UTF8"

    move-object v0, v7

    move-object/from16 v1, v20

    move-object/from16 v2, v21

    invoke-direct {v0, v1, v2}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end_2
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_2 .. :try_end_2} :catch_1

    .end local v6           #clientName:Ljava/lang/String;
    .local v7, clientName:Ljava/lang/String;
    move-object v6, v7

    .line 1393
    .end local v7           #clientName:Ljava/lang/String;
    .end local v8           #clientNameBuf:[B
    .restart local v6       #clientName:Ljava/lang/String;
    :cond_1
    :goto_1
    const/16 v20, 0x5

    aput-object v6, v17, v20

    .line 1396
    const/16 v20, 0x6

    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v21

    invoke-static/range {v21 .. v21}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object v21

    aput-object v21, v17, v20

    .line 1397
    add-int/lit8 v13, v13, 0x1

    .line 1400
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v11

    .line 1401
    add-int/lit8 v13, v13, 0x1

    .line 1402
    new-instance v5, Ljava/lang/String;

    const-string v20, ""

    move-object v0, v5

    move-object/from16 v1, v20

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>(Ljava/lang/String;)V

    .line 1403
    .local v5, clientExtAddr:Ljava/lang/String;
    if-lez v11, :cond_2

    .line 1404
    new-instance v5, Ljava/lang/String;

    .end local v5           #clientExtAddr:Ljava/lang/String;
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    move v3, v11

    invoke-direct {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/Supl;->readByteArray([BII)[B

    move-result-object v20

    move-object v0, v5

    move-object/from16 v1, v20

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>([B)V

    .line 1406
    .restart local v5       #clientExtAddr:Ljava/lang/String;
    :cond_2
    const/16 v20, 0x7

    aput-object v5, v17, v20

    .line 1408
    if-eqz v12, :cond_3

    .line 1409
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    move-object/from16 v20, v0

    monitor-enter v20

    .line 1410
    :try_start_3
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    move-object/from16 v21, v0

    move-object/from16 v0, v21

    move-object v1, v14

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 1411
    monitor-exit v20
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    .line 1414
    :cond_3
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/Supl;->mMtlr2Registrants:Landroid/os/RegistrantList;

    move-object/from16 v20, v0

    new-instance v21, Landroid/os/AsyncResult;

    const/16 v22, 0x0

    const/16 v23, 0x0

    move-object/from16 v0, v21

    move-object/from16 v1, v22

    move-object/from16 v2, v17

    move-object/from16 v3, v23

    invoke-direct {v0, v1, v2, v3}, Landroid/os/AsyncResult;-><init>(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Throwable;)V

    invoke-virtual/range {v20 .. v21}, Landroid/os/RegistrantList;->notifyRegistrants(Landroid/os/AsyncResult;)V

    .line 1415
    return-void

    .line 1342
    .end local v5           #clientExtAddr:Ljava/lang/String;
    .end local v6           #clientName:Ljava/lang/String;
    .end local v9           #codingSchema:B
    .end local v11           #length:B
    .end local v12           #notifyType:I
    .end local v15           #requestorId:Ljava/lang/String;
    .end local v17           #result:[Ljava/lang/Object;
    :catchall_0
    move-exception v21

    :try_start_4
    monitor-exit v20
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_0

    throw v21

    .line 1368
    .restart local v9       #codingSchema:B
    .restart local v11       #length:B
    .restart local v12       #notifyType:I
    .restart local v15       #requestorId:Ljava/lang/String;
    .restart local v17       #result:[Ljava/lang/Object;
    :catch_0
    move-exception v20

    move-object/from16 v10, v20

    .line 1369
    .local v10, ex:Ljava/io/UnsupportedEncodingException;
    const-string v20, "SUPLJ"

    const-string v21, "Unsupported Encoding: "

    move-object/from16 v0, v20

    move-object/from16 v1, v21

    move-object v2, v10

    invoke-static {v0, v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto/16 :goto_0

    .line 1388
    .end local v10           #ex:Ljava/io/UnsupportedEncodingException;
    .restart local v6       #clientName:Ljava/lang/String;
    .restart local v8       #clientNameBuf:[B
    :catch_1
    move-exception v20

    move-object/from16 v10, v20

    .line 1389
    .restart local v10       #ex:Ljava/io/UnsupportedEncodingException;
    const-string v20, "SUPLJ"

    const-string v21, "Unsupported Encoding: "

    move-object/from16 v0, v20

    move-object/from16 v1, v21

    move-object v2, v10

    invoke-static {v0, v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto/16 :goto_1

    .line 1411
    .end local v8           #clientNameBuf:[B
    .end local v10           #ex:Ljava/io/UnsupportedEncodingException;
    .restart local v5       #clientExtAddr:Ljava/lang/String;
    :catchall_1
    move-exception v21

    :try_start_5
    monitor-exit v20
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_1

    throw v21
.end method

.method private processMtlrRequest(Landroid/os/Parcel;)V
    .locals 22
    .parameter "p"

    .prologue
    .line 1213
    invoke-virtual/range {p1 .. p1}, Landroid/os/Parcel;->marshall()[B

    move-result-object v4

    .line 1214
    .local v4, buf:[B
    const/4 v13, 0x1

    .line 1215
    .local v13, offset:I
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v16

    .line 1216
    .local v16, sessionId:B
    add-int/lit8 v13, v13, 0x1

    .line 1217
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v17

    .line 1218
    .local v17, transactionId:B
    add-int/lit8 v13, v13, 0x1

    .line 1220
    const/16 v18, 0x13

    const/16 v19, 0x0

    move/from16 v0, v18

    move/from16 v1, v16

    move/from16 v2, v17

    move-object/from16 v3, v19

    invoke-static {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v14

    .line 1225
    .local v14, r:Lcom/motorola/android/locationproxy/SuplRequest;
    const/16 v18, 0x6

    move/from16 v0, v18

    new-array v0, v0, [Ljava/lang/Object;

    move-object v15, v0

    .line 1226
    .local v15, result:[Ljava/lang/Object;
    const/16 v18, 0x0

    move-object v0, v14

    iget v0, v0, Lcom/motorola/android/locationproxy/SuplRequest;->mSerial:I

    move/from16 v19, v0

    invoke-static/range {v19 .. v19}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v19

    aput-object v19, v15, v18

    .line 1229
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v12

    .line 1230
    .local v12, notifyType:I
    const/16 v18, 0x1

    invoke-static {v12}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v19

    aput-object v19, v15, v18

    .line 1231
    add-int/lit8 v13, v13, 0x4

    .line 1234
    const/16 v18, 0x2

    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v19

    invoke-static/range {v19 .. v19}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v19

    aput-object v19, v15, v18

    .line 1235
    add-int/lit8 v13, v13, 0x4

    .line 1241
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v9

    .line 1242
    .local v9, codingSchema:B
    add-int/lit8 v13, v13, 0x1

    .line 1244
    new-instance v6, Ljava/lang/String;

    const-string v18, ""

    move-object v0, v6

    move-object/from16 v1, v18

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>(Ljava/lang/String;)V

    .line 1246
    .local v6, clientName:Ljava/lang/String;
    const/16 v18, 0xff

    move v0, v9

    move/from16 v1, v18

    if-eq v0, v1, :cond_0

    .line 1247
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v18

    move/from16 v0, v18

    and-int/lit16 v0, v0, 0xff

    move v11, v0

    .line 1248
    .local v11, length:I
    add-int/lit8 v13, v13, 0x1

    .line 1249
    if-lez v11, :cond_0

    .line 1250
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    move v3, v11

    invoke-direct {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/Supl;->readByteArray([BII)[B

    move-result-object v8

    .line 1251
    .local v8, clientNameBuf:[B
    add-int/lit8 v13, v11, 0xd

    .line 1253
    :try_start_0
    new-instance v7, Ljava/lang/String;

    move-object/from16 v0, p0

    move-object v1, v8

    invoke-direct {v0, v1}, Lcom/motorola/android/locationproxy/Supl;->convertUcs2ToUtf8([B)[B

    move-result-object v18

    const-string v19, "UTF8"

    move-object v0, v7

    move-object/from16 v1, v18

    move-object/from16 v2, v19

    invoke-direct {v0, v1, v2}, Ljava/lang/String;-><init>([BLjava/lang/String;)V
    :try_end_0
    .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_0

    .end local v6           #clientName:Ljava/lang/String;
    .local v7, clientName:Ljava/lang/String;
    move-object v6, v7

    .line 1261
    .end local v7           #clientName:Ljava/lang/String;
    .end local v8           #clientNameBuf:[B
    .end local v11           #length:I
    .restart local v6       #clientName:Ljava/lang/String;
    :cond_0
    :goto_0
    const/16 v18, 0x3

    aput-object v6, v15, v18

    .line 1264
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v11

    .line 1265
    .local v11, length:B
    add-int/lit8 v13, v13, 0x1

    .line 1266
    new-instance v5, Ljava/lang/String;

    const-string v18, ""

    move-object v0, v5

    move-object/from16 v1, v18

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>(Ljava/lang/String;)V

    .line 1267
    .local v5, clientExtAddr:Ljava/lang/String;
    if-lez v11, :cond_1

    .line 1268
    new-instance v5, Ljava/lang/String;

    .end local v5           #clientExtAddr:Ljava/lang/String;
    move-object/from16 v0, p0

    move-object v1, v4

    move v2, v13

    move v3, v11

    invoke-direct {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/Supl;->readByteArray([BII)[B

    move-result-object v18

    move-object v0, v5

    move-object/from16 v1, v18

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>([B)V

    .line 1270
    .restart local v5       #clientExtAddr:Ljava/lang/String;
    :cond_1
    const/16 v18, 0x4

    aput-object v5, v15, v18

    .line 1272
    if-eqz v12, :cond_2

    .line 1273
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    move-object/from16 v18, v0

    monitor-enter v18

    .line 1274
    :try_start_1
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    move-object/from16 v19, v0

    move-object/from16 v0, v19

    move-object v1, v14

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 1275
    monitor-exit v18
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 1281
    :goto_1
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/Supl;->mMtlrRegistrants:Landroid/os/RegistrantList;

    move-object/from16 v18, v0

    new-instance v19, Landroid/os/AsyncResult;

    const/16 v20, 0x0

    const/16 v21, 0x0

    move-object/from16 v0, v19

    move-object/from16 v1, v20

    move-object v2, v15

    move-object/from16 v3, v21

    invoke-direct {v0, v1, v2, v3}, Landroid/os/AsyncResult;-><init>(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Throwable;)V

    invoke-virtual/range {v18 .. v19}, Landroid/os/RegistrantList;->notifyRegistrants(Landroid/os/AsyncResult;)V

    .line 1282
    return-void

    .line 1254
    .end local v5           #clientExtAddr:Ljava/lang/String;
    .restart local v8       #clientNameBuf:[B
    .local v11, length:I
    :catch_0
    move-exception v18

    move-object/from16 v10, v18

    .line 1255
    .local v10, ex:Ljava/io/UnsupportedEncodingException;
    const-string v18, "SUPLJ"

    const-string v19, "Unsupported Encoding"

    move-object/from16 v0, v18

    move-object/from16 v1, v19

    move-object v2, v10

    invoke-static {v0, v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_0

    .line 1275
    .end local v8           #clientNameBuf:[B
    .end local v10           #ex:Ljava/io/UnsupportedEncodingException;
    .restart local v5       #clientExtAddr:Ljava/lang/String;
    .local v11, length:B
    :catchall_0
    move-exception v19

    :try_start_2
    monitor-exit v18
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    throw v19

    .line 1278
    :cond_2
    invoke-virtual {v14}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    goto :goto_1
.end method

.method private processMtlrStatus(Landroid/os/Parcel;)V
    .locals 9
    .parameter "p"

    .prologue
    const/4 v8, 0x0

    .line 1420
    invoke-virtual {p1}, Landroid/os/Parcel;->marshall()[B

    move-result-object v0

    .line 1421
    .local v0, buf:[B
    const/4 v1, 0x1

    .line 1422
    .local v1, offset:I
    invoke-direct {p0, v0, v1}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v4

    .line 1423
    .local v4, sessionId:B
    add-int/lit8 v1, v1, 0x1

    .line 1424
    invoke-direct {p0, v0, v1}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v5

    .line 1425
    .local v5, transactionId:B
    add-int/lit8 v1, v1, 0x1

    .line 1427
    const/16 v6, 0x13

    invoke-direct {p0, v4, v5, v6}, Lcom/motorola/android/locationproxy/Supl;->findAndRemoveRequestFromList(BBB)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v2

    .line 1430
    .local v2, r:Lcom/motorola/android/locationproxy/SuplRequest;
    if-nez v2, :cond_0

    .line 1431
    const/16 v6, 0x20

    invoke-direct {p0, v4, v5, v6}, Lcom/motorola/android/locationproxy/Supl;->findAndRemoveRequestFromList(BBB)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v2

    .line 1436
    :cond_0
    if-nez v2, :cond_1

    .line 1437
    const-string v6, "SUPLJ"

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "MTLR request doesnot exist! sessiionId: "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v8, "transactionId: "

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v6, v7}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 1448
    :goto_0
    return-void

    .line 1442
    :cond_1
    const/4 v6, 0x2

    new-array v3, v6, [Ljava/lang/Object;

    .line 1443
    .local v3, result:[Ljava/lang/Object;
    const/4 v6, 0x0

    iget v7, v2, Lcom/motorola/android/locationproxy/SuplRequest;->mSerial:I

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    aput-object v7, v3, v6

    .line 1444
    const/4 v6, 0x1

    invoke-direct {p0, v0, v1}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v7

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v7

    aput-object v7, v3, v6

    .line 1446
    iget-object v6, p0, Lcom/motorola/android/locationproxy/Supl;->mMtlrStatusRegistrants:Landroid/os/RegistrantList;

    new-instance v7, Landroid/os/AsyncResult;

    invoke-direct {v7, v8, v3, v8}, Landroid/os/AsyncResult;-><init>(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Throwable;)V

    invoke-virtual {v6, v7}, Landroid/os/RegistrantList;->notifyRegistrants(Landroid/os/AsyncResult;)V

    .line 1447
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    goto :goto_0
.end method

.method private processOpenSocketRequest(Landroid/os/Parcel;)V
    .locals 12
    .parameter "p"

    .prologue
    const/4 v11, 0x5

    const/4 v10, 0x0

    .line 1066
    invoke-virtual {p1}, Landroid/os/Parcel;->marshall()[B

    move-result-object v0

    .line 1067
    .local v0, buf:[B
    const/4 v3, 0x1

    .line 1068
    .local v3, offset:I
    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v6

    .line 1069
    .local v6, sessionId:B
    add-int/lit8 v3, v3, 0x1

    .line 1070
    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v7

    .line 1071
    .local v7, transactionId:B
    add-int/lit8 v3, v3, 0x1

    .line 1073
    const/16 v8, 0x9

    invoke-static {v8, v6, v7, v10}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v4

    .line 1077
    .local v4, r:Lcom/motorola/android/locationproxy/SuplRequest;
    iget-object v8, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    monitor-enter v8

    .line 1078
    :try_start_0
    iget-object v9, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v9, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 1079
    monitor-exit v8
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 1081
    const/4 v8, 0x6

    new-array v5, v8, [Ljava/lang/Object;

    .line 1082
    .local v5, result:[Ljava/lang/Object;
    const/4 v8, 0x0

    iget v9, v4, Lcom/motorola/android/locationproxy/SuplRequest;->mSerial:I

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v9

    aput-object v9, v5, v8

    .line 1084
    const/4 v8, 0x1

    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v9

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v9

    aput-object v9, v5, v8

    .line 1085
    add-int/lit8 v3, v3, 0x4

    .line 1087
    const/4 v8, 0x2

    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v9

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v9

    aput-object v9, v5, v8

    .line 1088
    add-int/lit8 v3, v3, 0x4

    .line 1090
    const/4 v8, 0x3

    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readShort([BI)S

    move-result v9

    invoke-static {v9}, Ljava/lang/Short;->valueOf(S)Ljava/lang/Short;

    move-result-object v9

    aput-object v9, v5, v8

    .line 1091
    add-int/lit8 v3, v3, 0x2

    .line 1093
    const/4 v8, 0x4

    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v9

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v9

    aput-object v9, v5, v8

    .line 1094
    add-int/lit8 v3, v3, 0x4

    .line 1096
    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v8

    and-int/lit16 v2, v8, 0xff

    .line 1097
    .local v2, dnsLength:I
    add-int/lit8 v3, v3, 0x1

    .line 1098
    if-lez v2, :cond_0

    .line 1099
    invoke-direct {p0, v0, v3, v2}, Lcom/motorola/android/locationproxy/Supl;->readByteArray([BII)[B

    move-result-object v1

    .line 1100
    .local v1, dns:[B
    aput-object v1, v5, v11

    .line 1104
    .end local v1           #dns:[B
    :goto_0
    iget-object v8, p0, Lcom/motorola/android/locationproxy/Supl;->mOpenSocketRegistrants:Landroid/os/RegistrantList;

    new-instance v9, Landroid/os/AsyncResult;

    invoke-direct {v9, v10, v5, v10}, Landroid/os/AsyncResult;-><init>(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Throwable;)V

    invoke-virtual {v8, v9}, Landroid/os/RegistrantList;->notifyRegistrants(Landroid/os/AsyncResult;)V

    .line 1105
    return-void

    .line 1079
    .end local v2           #dnsLength:I
    .end local v5           #result:[Ljava/lang/Object;
    :catchall_0
    move-exception v9

    :try_start_1
    monitor-exit v8
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v9

    .line 1102
    .restart local v2       #dnsLength:I
    .restart local v5       #result:[Ljava/lang/Object;
    :cond_0
    aput-object v10, v5, v11

    goto :goto_0
.end method

.method private processResponse(Landroid/os/Parcel;)V
    .locals 5
    .parameter "p"

    .prologue
    .line 848
    invoke-virtual {p1}, Landroid/os/Parcel;->marshall()[B

    move-result-object v0

    .line 850
    .local v0, msg:[B
    const/4 v2, 0x0

    aget-byte v1, v0, v2

    .line 852
    .local v1, subCommandId:B
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Handle SubCMD "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-static {v1}, Lcom/motorola/android/locationproxy/Supl;->SubCommandIdToString(B)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-direct {p0, v2}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 854
    sparse-switch v1, :sswitch_data_0

    .line 892
    const-string v2, "SUPLJ"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "Invalid supl event"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-static {v1}, Lcom/motorola/android/locationproxy/Supl;->SubCommandIdToString(B)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 895
    :goto_0
    return-void

    .line 856
    :sswitch_0
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->processDbWriteResult(Landroid/os/Parcel;)V

    goto :goto_0

    .line 860
    :sswitch_1
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->processDbReadResult(Landroid/os/Parcel;)V

    goto :goto_0

    .line 864
    :sswitch_2
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->processOpenSocketRequest(Landroid/os/Parcel;)V

    goto :goto_0

    .line 868
    :sswitch_3
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->processSocketDataRequest(Landroid/os/Parcel;)V

    goto :goto_0

    .line 872
    :sswitch_4
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->processCloseSocketRequest(Landroid/os/Parcel;)V

    goto :goto_0

    .line 876
    :sswitch_5
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->processTlsSessionRequest(Landroid/os/Parcel;)V

    goto :goto_0

    .line 880
    :sswitch_6
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->processMtlrRequest(Landroid/os/Parcel;)V

    goto :goto_0

    .line 884
    :sswitch_7
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->processMtlr2Request(Landroid/os/Parcel;)V

    goto :goto_0

    .line 888
    :sswitch_8
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->processMtlrStatus(Landroid/os/Parcel;)V

    goto :goto_0

    .line 854
    nop

    :sswitch_data_0
    .sparse-switch
        0x5 -> :sswitch_0
        0x7 -> :sswitch_1
        0x9 -> :sswitch_2
        0xb -> :sswitch_3
        0xe -> :sswitch_4
        0x13 -> :sswitch_6
        0x15 -> :sswitch_8
        0x1e -> :sswitch_5
        0x20 -> :sswitch_7
    .end sparse-switch
.end method

.method private processSocketDataRequest(Landroid/os/Parcel;)V
    .locals 12
    .parameter "p"

    .prologue
    const/4 v11, 0x2

    const/4 v10, 0x0

    .line 1109
    invoke-virtual {p1}, Landroid/os/Parcel;->marshall()[B

    move-result-object v0

    .line 1110
    .local v0, buf:[B
    const/4 v3, 0x1

    .line 1111
    .local v3, offset:I
    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v6

    .line 1112
    .local v6, sessionId:B
    add-int/lit8 v3, v3, 0x1

    .line 1113
    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v7

    .line 1114
    .local v7, transactionId:B
    add-int/lit8 v3, v3, 0x1

    .line 1116
    const/16 v8, 0xb

    invoke-static {v8, v6, v7, v10}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v4

    .line 1120
    .local v4, r:Lcom/motorola/android/locationproxy/SuplRequest;
    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v4}, Lcom/motorola/android/locationproxy/SuplRequest;->serialString()Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, "> "

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    iget-byte v9, v4, Lcom/motorola/android/locationproxy/SuplRequest;->mSubCommandId:B

    invoke-static {v9}, Lcom/motorola/android/locationproxy/Supl;->SubCommandIdToString(B)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-direct {p0, v8}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 1121
    iget-object v8, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    monitor-enter v8

    .line 1122
    :try_start_0
    iget-object v9, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v9, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 1123
    monitor-exit v8
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 1125
    const/4 v8, 0x3

    new-array v5, v8, [Ljava/lang/Object;

    .line 1126
    .local v5, result:[Ljava/lang/Object;
    const/4 v8, 0x0

    iget v9, v4, Lcom/motorola/android/locationproxy/SuplRequest;->mSerial:I

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v9

    aput-object v9, v5, v8

    .line 1129
    const/4 v8, 0x1

    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v9

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v9

    aput-object v9, v5, v8

    .line 1130
    add-int/lit8 v3, v3, 0x4

    .line 1133
    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v2

    .line 1134
    .local v2, dataLength:I
    add-int/lit8 v3, v3, 0x4

    .line 1135
    if-lez v2, :cond_0

    .line 1136
    invoke-direct {p0, v0, v3, v2}, Lcom/motorola/android/locationproxy/Supl;->readByteArray([BII)[B

    move-result-object v1

    .line 1137
    .local v1, data:[B
    aput-object v1, v5, v11

    .line 1142
    .end local v1           #data:[B
    :goto_0
    iget-object v8, p0, Lcom/motorola/android/locationproxy/Supl;->mSocketDataRegistrants:Landroid/os/RegistrantList;

    new-instance v9, Landroid/os/AsyncResult;

    invoke-direct {v9, v10, v5, v10}, Landroid/os/AsyncResult;-><init>(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Throwable;)V

    invoke-virtual {v8, v9}, Landroid/os/RegistrantList;->notifyRegistrants(Landroid/os/AsyncResult;)V

    .line 1143
    return-void

    .line 1123
    .end local v2           #dataLength:I
    .end local v5           #result:[Ljava/lang/Object;
    :catchall_0
    move-exception v9

    :try_start_1
    monitor-exit v8
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v9

    .line 1139
    .restart local v2       #dataLength:I
    .restart local v5       #result:[Ljava/lang/Object;
    :cond_0
    aput-object v10, v5, v11

    .line 1140
    const-string v8, "SUPLJ"

    const-string v9, "No data to be fwd"

    invoke-static {v8, v9}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method

.method private processTlsSessionRequest(Landroid/os/Parcel;)V
    .locals 12
    .parameter "p"

    .prologue
    const/4 v11, 0x2

    const/4 v10, 0x0

    .line 1175
    invoke-virtual {p1}, Landroid/os/Parcel;->marshall()[B

    move-result-object v0

    .line 1176
    .local v0, buf:[B
    const/4 v3, 0x1

    .line 1177
    .local v3, offset:I
    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v6

    .line 1178
    .local v6, sessionId:B
    add-int/lit8 v3, v3, 0x1

    .line 1179
    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v7

    .line 1180
    .local v7, transactionId:B
    add-int/lit8 v3, v3, 0x1

    .line 1182
    const/16 v8, 0x1e

    invoke-static {v8, v6, v7, v10}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v4

    .line 1186
    .local v4, r:Lcom/motorola/android/locationproxy/SuplRequest;
    iget-object v8, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    monitor-enter v8

    .line 1187
    :try_start_0
    iget-object v9, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v9, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 1188
    monitor-exit v8
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 1190
    const/4 v8, 0x3

    new-array v5, v8, [Ljava/lang/Object;

    .line 1191
    .local v5, result:[Ljava/lang/Object;
    const/4 v8, 0x0

    iget v9, v4, Lcom/motorola/android/locationproxy/SuplRequest;->mSerial:I

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v9

    aput-object v9, v5, v8

    .line 1194
    const/4 v8, 0x1

    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readInt([BI)I

    move-result v9

    invoke-static {v9}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v9

    aput-object v9, v5, v8

    .line 1195
    add-int/lit8 v3, v3, 0x4

    .line 1198
    invoke-direct {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readByte([BI)B

    move-result v8

    and-int/lit16 v2, v8, 0xfe

    .line 1199
    .local v2, fqdnLength:I
    add-int/lit8 v3, v3, 0x1

    .line 1200
    if-lez v2, :cond_0

    .line 1201
    invoke-direct {p0, v0, v3, v2}, Lcom/motorola/android/locationproxy/Supl;->readByteArray([BII)[B

    move-result-object v1

    .line 1202
    .local v1, fqdn:[B
    aput-object v1, v5, v11

    .line 1208
    .end local v1           #fqdn:[B
    :goto_0
    iget-object v8, p0, Lcom/motorola/android/locationproxy/Supl;->mTlsRegistrants:Landroid/os/RegistrantList;

    new-instance v9, Landroid/os/AsyncResult;

    invoke-direct {v9, v10, v5, v10}, Landroid/os/AsyncResult;-><init>(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Throwable;)V

    invoke-virtual {v8, v9}, Landroid/os/RegistrantList;->notifyRegistrants(Landroid/os/AsyncResult;)V

    .line 1209
    return-void

    .line 1188
    .end local v2           #fqdnLength:I
    .end local v5           #result:[Ljava/lang/Object;
    :catchall_0
    move-exception v9

    :try_start_1
    monitor-exit v8
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v9

    .line 1204
    .restart local v2       #fqdnLength:I
    .restart local v5       #result:[Ljava/lang/Object;
    :cond_0
    const-string v8, "LOG_TAG"

    const-string v9, "fqdn length is 0"

    invoke-static {v8, v9}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 1205
    aput-object v10, v5, v11

    goto :goto_0
.end method

.method private readByte([BI)B
    .locals 1
    .parameter "buf"
    .parameter "offset"

    .prologue
    .line 937
    aget-byte v0, p1, p2

    return v0
.end method

.method private readByteArray([BII)[B
    .locals 4
    .parameter "buf"
    .parameter "offset"
    .parameter "length"

    .prologue
    .line 941
    new-array v2, p3, [B

    .line 942
    .local v2, val:[B
    const/4 v0, 0x0

    .local v0, i:I
    move v1, p2

    .end local p2
    .local v1, offset:I
    :goto_0
    if-ge v0, p3, :cond_0

    .line 943
    add-int/lit8 p2, v1, 0x1

    .end local v1           #offset:I
    .restart local p2
    aget-byte v3, p1, v1

    aput-byte v3, v2, v0

    .line 942
    add-int/lit8 v0, v0, 0x1

    move v1, p2

    .end local p2
    .restart local v1       #offset:I
    goto :goto_0

    .line 945
    :cond_0
    return-object v2
.end method

.method private static readCommandId(Ljava/io/InputStream;)B
    .locals 4
    .parameter "is"
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    const/4 v3, 0x0

    const/4 v2, 0x1

    .line 253
    new-array v0, v2, [B

    .line 254
    .local v0, buf:[B
    invoke-static {p0, v0, v2}, Lcom/motorola/android/locationproxy/Supl;->readSocket(Ljava/io/InputStream;[BI)I

    move-result v1

    if-eq v1, v2, :cond_0

    .line 255
    const-string v1, "SUPLJ"

    const-string v2, "Reading CommandID Error"

    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    move v1, v3

    .line 258
    :goto_0
    return v1

    :cond_0
    aget-byte v1, v0, v3

    goto :goto_0
.end method

.method private readInt([BI)I
    .locals 3
    .parameter "buf"
    .parameter "offset"

    .prologue
    .line 956
    add-int/lit8 v0, p2, 0x1

    .end local p2
    .local v0, offset:I
    aget-byte v2, p1, p2

    and-int/lit16 v1, v2, 0xff

    .line 957
    .local v1, val:I
    shl-int/lit8 v1, v1, 0x8

    .line 958
    add-int/lit8 p2, v0, 0x1

    .end local v0           #offset:I
    .restart local p2
    aget-byte v2, p1, v0

    and-int/lit16 v2, v2, 0xff

    or-int/2addr v1, v2

    .line 959
    shl-int/lit8 v1, v1, 0x8

    .line 960
    add-int/lit8 v0, p2, 0x1

    .end local p2
    .restart local v0       #offset:I
    aget-byte v2, p1, p2

    and-int/lit16 v2, v2, 0xff

    or-int/2addr v1, v2

    .line 961
    shl-int/lit8 v1, v1, 0x8

    .line 962
    add-int/lit8 p2, v0, 0x1

    .end local v0           #offset:I
    .restart local p2
    aget-byte v2, p1, v0

    and-int/lit16 v2, v2, 0xff

    or-int/2addr v1, v2

    .line 963
    return v1
.end method

.method private static readMessageLength(Ljava/io/InputStream;)S
    .locals 5
    .parameter "is"
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    const/4 v4, 0x0

    const/4 v3, 0x2

    .line 263
    new-array v0, v3, [B

    .line 264
    .local v0, buf:[B
    invoke-static {p0, v0, v3}, Lcom/motorola/android/locationproxy/Supl;->readSocket(Ljava/io/InputStream;[BI)I

    move-result v2

    if-eq v2, v3, :cond_0

    .line 265
    const-string v2, "SUPLJ"

    const-string v3, "Reading Message Length ERROR"

    invoke-static {v2, v3}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    move v2, v4

    .line 273
    :goto_0
    return v2

    .line 269
    :cond_0
    const/4 v1, 0x0

    .line 270
    .local v1, length:S
    aget-byte v2, v0, v4

    and-int/lit16 v2, v2, 0xff

    or-int/2addr v2, v1

    int-to-short v1, v2

    .line 271
    shl-int/lit8 v2, v1, 0x8

    int-to-short v1, v2

    .line 272
    const/4 v2, 0x1

    aget-byte v2, v0, v2

    and-int/lit16 v2, v2, 0xff

    or-int/2addr v2, v1

    int-to-short v1, v2

    move v2, v1

    .line 273
    goto :goto_0
.end method

.method private readShort([BI)S
    .locals 3
    .parameter "buf"
    .parameter "offset"

    .prologue
    .line 949
    add-int/lit8 v0, p2, 0x1

    .end local p2
    .local v0, offset:I
    aget-byte v2, p1, p2

    and-int/lit16 v1, v2, 0xff

    .line 950
    .local v1, val:I
    shl-int/lit8 v1, v1, 0x8

    .line 951
    aget-byte v2, p1, v0

    and-int/lit16 v2, v2, 0xff

    or-int/2addr v1, v2

    .line 952
    const v2, 0xffff

    and-int/2addr v2, v1

    int-to-short v2, v2

    return v2
.end method

.method private static readSocket(Ljava/io/InputStream;[BI)I
    .locals 5
    .parameter "is"
    .parameter "buffer"
    .parameter "length"
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 233
    const/4 v0, 0x0

    .line 234
    .local v0, countRead:I
    const/4 v1, 0x0

    .line 235
    .local v1, offset:I
    move v2, p2

    .line 238
    .local v2, remaining:I
    :cond_0
    invoke-virtual {p0, p1, v1, v2}, Ljava/io/InputStream;->read([BII)I

    move-result v0

    .line 240
    if-gez v0, :cond_1

    .line 241
    const-string v3, "SUPLJ"

    const-string v4, "Reading Socket ERROR"

    invoke-static {v3, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 242
    const/4 v3, -0x1

    .line 248
    :goto_0
    return v3

    .line 245
    :cond_1
    add-int/2addr v1, v0

    .line 246
    sub-int/2addr v2, v0

    .line 247
    if-gtz v2, :cond_0

    .line 248
    sub-int v3, p2, v2

    goto :goto_0
.end method

.method private static readSuplMessage(Ljava/io/InputStream;[B)I
    .locals 6
    .parameter "is"
    .parameter "buffer"
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    const/4 v5, -0x1

    const-string v4, "SUPLJ"

    .line 280
    invoke-static {p0}, Lcom/motorola/android/locationproxy/Supl;->readCommandId(Ljava/io/InputStream;)B

    move-result v2

    const/16 v3, 0x50

    if-eq v2, v3, :cond_0

    .line 281
    const-string v2, "SUPLJ"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Unknown cmd: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const/4 v3, 0x0

    aget-byte v3, p1, v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    move v2, v5

    .line 298
    :goto_0
    return v2

    .line 286
    :cond_0
    invoke-static {p0}, Lcom/motorola/android/locationproxy/Supl;->readMessageLength(Ljava/io/InputStream;)S

    move-result v1

    .line 287
    .local v1, messageLength:I
    const-string v2, "SUPLJ"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "msg length: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Landroid/util/Log;->v(Ljava/lang/String;Ljava/lang/String;)I

    .line 289
    const/4 v2, 0x5

    sub-int v0, v1, v2

    .line 290
    .local v0, bodyLength:I
    add-int/lit8 v2, v0, 0x2

    invoke-static {p0, p1, v2}, Lcom/motorola/android/locationproxy/Supl;->readSocket(Ljava/io/InputStream;[BI)I

    .line 292
    aget-byte v2, p1, v0

    const/16 v3, -0x31

    if-ne v2, v3, :cond_1

    add-int/lit8 v2, v0, 0x1

    aget-byte v2, p1, v2

    const/16 v3, -0x50

    if-eq v2, v3, :cond_2

    .line 294
    :cond_1
    const-string v2, "SUPLJ"

    const-string v2, "NO tail marker"

    invoke-static {v4, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    move v2, v5

    .line 295
    goto :goto_0

    :cond_2
    move v2, v0

    .line 298
    goto :goto_0
.end method

.method private send(Lcom/motorola/android/locationproxy/SuplRequest;)V
    .locals 7
    .parameter "r"
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    const-string v6, "SUPLJ"

    .line 830
    :try_start_0
    iget-object v2, p0, Lcom/motorola/android/locationproxy/Supl;->mSocket:Landroid/net/LocalSocket;

    .line 831
    .local v2, s:Landroid/net/LocalSocket;
    if-nez v2, :cond_0

    .line 844
    :goto_0
    return-void

    .line 835
    :cond_0
    invoke-virtual {p1}, Lcom/motorola/android/locationproxy/SuplRequest;->getData()[B

    move-result-object v0

    .line 836
    .local v0, data:[B
    invoke-direct {p0, v0}, Lcom/motorola/android/locationproxy/Supl;->logSuplApBpRequest([B)V

    .line 838
    const-string v3, "SUPLJ"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "writing packet: "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    array-length v5, v0

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, " bytes"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 839
    invoke-virtual {v2}, Landroid/net/LocalSocket;->getOutputStream()Ljava/io/OutputStream;

    move-result-object v3

    invoke-virtual {v3, v0}, Ljava/io/OutputStream;->write([B)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 840
    .end local v0           #data:[B
    .end local v2           #s:Landroid/net/LocalSocket;
    :catch_0
    move-exception v3

    move-object v1, v3

    .line 841
    .local v1, ex:Ljava/io/IOException;
    const-string v3, "SUPLJ"

    const-string v3, "IOException"

    invoke-static {v6, v3, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 842
    throw v1
.end method

.method private suplLog(Ljava/lang/String;)V
    .locals 1
    .parameter "msg"

    .prologue
    .line 1476
    const-string v0, "SUPLJ"

    invoke-static {v0, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 1477
    return-void
.end method


# virtual methods
.method public forwardSocketData(I[BI)V
    .locals 7
    .parameter "linkId"
    .parameter "data"
    .parameter "result"

    .prologue
    const/4 v6, 0x0

    .line 531
    const/16 v4, 0xd

    const/4 v5, 0x0

    invoke-static {v4, v6, v6, v5}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v3

    .line 536
    .local v3, r:Lcom/motorola/android/locationproxy/SuplRequest;
    array-length v0, p2

    .line 544
    .local v0, dataLength:I
    sget v4, Lcom/motorola/android/locationproxy/SuplRequest;->sHeaderLength:I

    add-int/lit8 v4, v4, 0x4

    add-int/lit8 v4, v4, 0x4

    add-int/2addr v4, v0

    add-int/lit8 v4, v4, 0x4

    sget v5, Lcom/motorola/android/locationproxy/SuplRequest;->sTailLength:I

    add-int v2, v4, v5

    .line 545
    .local v2, length:I
    invoke-virtual {v3, v2}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataCapacity(I)V

    .line 546
    invoke-virtual {v3, v6}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataPosition(I)V

    .line 548
    invoke-virtual {v3}, Lcom/motorola/android/locationproxy/SuplRequest;->writeHeader()V

    .line 549
    invoke-virtual {v3, p1}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 550
    invoke-virtual {v3, v0}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 551
    invoke-virtual {v3, p2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeByteArray([B)V

    .line 552
    invoke-virtual {v3, p3}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 553
    const/16 v4, -0x3050

    invoke-virtual {v3, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->writeShort(S)V

    .line 555
    :try_start_0
    invoke-direct {p0, v3}, Lcom/motorola/android/locationproxy/Supl;->send(Lcom/motorola/android/locationproxy/SuplRequest;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 559
    :goto_0
    invoke-virtual {v3}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 560
    return-void

    .line 556
    :catch_0
    move-exception v1

    .line 557
    .local v1, ex:Ljava/io/IOException;
    const/4 v4, 0x2

    invoke-virtual {v3, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->onError(I)V

    goto :goto_0
.end method

.method public getDefaultConfigFQDN()Ljava/lang/String;
    .locals 8

    .prologue
    const/4 v7, 0x0

    .line 662
    invoke-static {}, Landroid/os/Message;->obtain()Landroid/os/Message;

    move-result-object v3

    .line 664
    .local v3, result:Landroid/os/Message;
    const/4 v4, 0x6

    invoke-direct {p0}, Lcom/motorola/android/locationproxy/Supl;->generateSessionID()B

    move-result v5

    invoke-direct {p0}, Lcom/motorola/android/locationproxy/Supl;->generateTransactionId()B

    move-result v6

    invoke-static {v4, v5, v6, v3}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v2

    .line 673
    .local v2, r:Lcom/motorola/android/locationproxy/SuplRequest;
    sget v4, Lcom/motorola/android/locationproxy/SuplRequest;->sHeaderLength:I

    add-int/lit8 v4, v4, 0x4

    sget v5, Lcom/motorola/android/locationproxy/SuplRequest;->sTailLength:I

    add-int v1, v4, v5

    .line 674
    .local v1, length:I
    invoke-virtual {v2, v1}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataCapacity(I)V

    .line 675
    const/4 v4, 0x0

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataPosition(I)V

    .line 677
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeHeader()V

    .line 678
    const/high16 v4, 0x8

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 679
    const/16 v4, -0x3050

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->writeShort(S)V

    .line 682
    sget-object v4, Lcom/motorola/android/locationproxy/Supl;->sFqdnReadLock:Ljava/lang/Object;

    monitor-enter v4

    .line 683
    :try_start_0
    iget-object v5, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    monitor-enter v5
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    .line 685
    :try_start_1
    invoke-direct {p0, v2}, Lcom/motorola/android/locationproxy/Supl;->send(Lcom/motorola/android/locationproxy/SuplRequest;)V

    .line 686
    iget-object v6, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v6, v2}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_0

    .line 692
    :try_start_2
    monitor-exit v5
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 694
    :try_start_3
    const-string v5, "*** calling sFqdnReadLock.wait()"

    invoke-direct {p0, v5}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 695
    sget-object v5, Lcom/motorola/android/locationproxy/Supl;->sFqdnReadLock:Ljava/lang/Object;

    invoke-virtual {v5}, Ljava/lang/Object;->wait()V

    .line 696
    const-string v5, "*** finish sFqdnReadLock.wait()"

    invoke-direct {p0, v5}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1
    .catch Ljava/lang/InterruptedException; {:try_start_3 .. :try_end_3} :catch_1

    .line 703
    :try_start_4
    monitor-exit v4
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_1

    .line 705
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 706
    invoke-virtual {v3}, Landroid/os/Message;->recycle()V

    .line 707
    iget-object v4, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnAddr:Ljava/lang/String;

    :goto_0
    return-object v4

    .line 687
    :catch_0
    move-exception v6

    move-object v0, v6

    .line 688
    .local v0, ex:Ljava/io/IOException;
    :try_start_5
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 689
    invoke-virtual {v3}, Landroid/os/Message;->recycle()V

    .line 690
    monitor-exit v5
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_0

    :try_start_6
    monitor-exit v4
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_1

    move-object v4, v7

    goto :goto_0

    .line 692
    .end local v0           #ex:Ljava/io/IOException;
    :catchall_0
    move-exception v6

    :try_start_7
    monitor-exit v5
    :try_end_7
    .catchall {:try_start_7 .. :try_end_7} :catchall_0

    :try_start_8
    throw v6

    .line 703
    :catchall_1
    move-exception v5

    monitor-exit v4
    :try_end_8
    .catchall {:try_start_8 .. :try_end_8} :catchall_1

    throw v5

    .line 697
    :catch_1
    move-exception v5

    move-object v0, v5

    .line 698
    .local v0, ex:Ljava/lang/InterruptedException;
    :try_start_9
    const-string v5, "SUPLJ"

    const-string v6, "got InterruptedException!"

    invoke-static {v5, v6}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 699
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 700
    invoke-virtual {v3}, Landroid/os/Message;->recycle()V

    .line 701
    monitor-exit v4
    :try_end_9
    .catchall {:try_start_9 .. :try_end_9} :catchall_1

    move-object v4, v7

    goto :goto_0
.end method

.method public getUserConfigFQDN()Ljava/lang/String;
    .locals 8

    .prologue
    const/4 v7, 0x0

    .line 711
    const-string v4, "Getting user config FQDN"

    invoke-direct {p0, v4}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 712
    invoke-static {}, Landroid/os/Message;->obtain()Landroid/os/Message;

    move-result-object v3

    .line 713
    .local v3, result:Landroid/os/Message;
    const/4 v4, 0x6

    invoke-direct {p0}, Lcom/motorola/android/locationproxy/Supl;->generateSessionID()B

    move-result v5

    invoke-direct {p0}, Lcom/motorola/android/locationproxy/Supl;->generateTransactionId()B

    move-result v6

    invoke-static {v4, v5, v6, v3}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v2

    .line 722
    .local v2, r:Lcom/motorola/android/locationproxy/SuplRequest;
    sget v4, Lcom/motorola/android/locationproxy/SuplRequest;->sHeaderLength:I

    add-int/lit8 v4, v4, 0x4

    sget v5, Lcom/motorola/android/locationproxy/SuplRequest;->sTailLength:I

    add-int v1, v4, v5

    .line 723
    .local v1, length:I
    invoke-virtual {v2, v1}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataCapacity(I)V

    .line 724
    const/4 v4, 0x0

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataPosition(I)V

    .line 726
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeHeader()V

    .line 727
    const/high16 v4, 0x4

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 728
    const/16 v4, -0x3050

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->writeShort(S)V

    .line 731
    sget-object v4, Lcom/motorola/android/locationproxy/Supl;->sFqdnReadLock:Ljava/lang/Object;

    monitor-enter v4

    .line 732
    :try_start_0
    iget-object v5, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    monitor-enter v5
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    .line 734
    :try_start_1
    invoke-direct {p0, v2}, Lcom/motorola/android/locationproxy/Supl;->send(Lcom/motorola/android/locationproxy/SuplRequest;)V

    .line 735
    iget-object v6, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v6, v2}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_0

    .line 741
    :try_start_2
    monitor-exit v5
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 743
    :try_start_3
    const-string v5, "*** calling sFqdnReadLock.wait()"

    invoke-direct {p0, v5}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 744
    sget-object v5, Lcom/motorola/android/locationproxy/Supl;->sFqdnReadLock:Ljava/lang/Object;

    invoke-virtual {v5}, Ljava/lang/Object;->wait()V

    .line 745
    const-string v5, "*** finish sFqdnReadLock.wait()"

    invoke-direct {p0, v5}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1
    .catch Ljava/lang/InterruptedException; {:try_start_3 .. :try_end_3} :catch_1

    .line 752
    :try_start_4
    monitor-exit v4
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_1

    .line 754
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 755
    invoke-virtual {v3}, Landroid/os/Message;->recycle()V

    .line 756
    iget-object v4, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnAddr:Ljava/lang/String;

    :goto_0
    return-object v4

    .line 736
    :catch_0
    move-exception v6

    move-object v0, v6

    .line 737
    .local v0, ex:Ljava/io/IOException;
    :try_start_5
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 738
    invoke-virtual {v3}, Landroid/os/Message;->recycle()V

    .line 739
    monitor-exit v5
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_0

    :try_start_6
    monitor-exit v4
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_1

    move-object v4, v7

    goto :goto_0

    .line 741
    .end local v0           #ex:Ljava/io/IOException;
    :catchall_0
    move-exception v6

    :try_start_7
    monitor-exit v5
    :try_end_7
    .catchall {:try_start_7 .. :try_end_7} :catchall_0

    :try_start_8
    throw v6

    .line 752
    :catchall_1
    move-exception v5

    monitor-exit v4
    :try_end_8
    .catchall {:try_start_8 .. :try_end_8} :catchall_1

    throw v5

    .line 746
    :catch_1
    move-exception v5

    move-object v0, v5

    .line 747
    .local v0, ex:Ljava/lang/InterruptedException;
    :try_start_9
    const-string v5, "SUPLJ"

    const-string v6, "got InterruptedException!"

    invoke-static {v5, v6}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 748
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 749
    invoke-virtual {v3}, Landroid/os/Message;->recycle()V

    .line 750
    monitor-exit v4
    :try_end_9
    .catchall {:try_start_9 .. :try_end_9} :catchall_1

    move-object v4, v7

    goto :goto_0
.end method

.method public sendCloseSocketResult(III)V
    .locals 8
    .parameter "id"
    .parameter "linkId"
    .parameter "result"

    .prologue
    .line 466
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->findAndRemoveRequestFromList(I)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v3

    .line 467
    .local v3, req:Lcom/motorola/android/locationproxy/SuplRequest;
    if-nez v3, :cond_0

    .line 468
    const-string v4, "SUPLJ"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "Invalid ID: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 496
    :goto_0
    return-void

    .line 472
    :cond_0
    const/16 v4, 0xf

    iget-byte v5, v3, Lcom/motorola/android/locationproxy/SuplRequest;->mSessionId:B

    iget-byte v6, v3, Lcom/motorola/android/locationproxy/SuplRequest;->mTransactionId:B

    const/4 v7, 0x0

    invoke-static {v4, v5, v6, v7}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v2

    .line 476
    .local v2, r:Lcom/motorola/android/locationproxy/SuplRequest;
    invoke-virtual {v3}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 482
    sget v4, Lcom/motorola/android/locationproxy/SuplRequest;->sHeaderLength:I

    add-int/lit8 v4, v4, 0x4

    add-int/lit8 v4, v4, 0x4

    sget v5, Lcom/motorola/android/locationproxy/SuplRequest;->sTailLength:I

    add-int v1, v4, v5

    .line 483
    .local v1, length:I
    invoke-virtual {v2, v1}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataCapacity(I)V

    .line 484
    const/4 v4, 0x0

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataPosition(I)V

    .line 485
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeHeader()V

    .line 486
    invoke-virtual {v2, p2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 487
    invoke-virtual {v2, p3}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 488
    const/16 v4, -0x3050

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->writeShort(S)V

    .line 491
    :try_start_0
    invoke-direct {p0, v2}, Lcom/motorola/android/locationproxy/Supl;->send(Lcom/motorola/android/locationproxy/SuplRequest;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 495
    :goto_1
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    goto :goto_0

    .line 492
    :catch_0
    move-exception v0

    .line 493
    .local v0, ex:Ljava/io/IOException;
    const/4 v4, 0x2

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->onError(I)V

    goto :goto_1
.end method

.method public sendLocationRequestResponse(II)V
    .locals 8
    .parameter "id"
    .parameter "response_type"

    .prologue
    .line 563
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->findAndRemoveRequestFromList(I)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v3

    .line 564
    .local v3, req:Lcom/motorola/android/locationproxy/SuplRequest;
    if-nez v3, :cond_0

    .line 565
    const-string v4, "SUPLJ"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "Invalid ID: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 593
    :goto_0
    return-void

    .line 569
    :cond_0
    const/16 v4, 0x14

    iget-byte v5, v3, Lcom/motorola/android/locationproxy/SuplRequest;->mSessionId:B

    iget-byte v6, v3, Lcom/motorola/android/locationproxy/SuplRequest;->mTransactionId:B

    const/4 v7, 0x0

    invoke-static {v4, v5, v6, v7}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v2

    .line 573
    .local v2, r:Lcom/motorola/android/locationproxy/SuplRequest;
    invoke-virtual {v3}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 580
    sget v4, Lcom/motorola/android/locationproxy/SuplRequest;->sHeaderLength:I

    add-int/lit8 v4, v4, 0x4

    sget v5, Lcom/motorola/android/locationproxy/SuplRequest;->sTailLength:I

    add-int v1, v4, v5

    .line 581
    .local v1, length:I
    invoke-virtual {v2, v1}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataCapacity(I)V

    .line 582
    const/4 v4, 0x0

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataPosition(I)V

    .line 584
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeHeader()V

    .line 585
    invoke-virtual {v2, p2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 586
    const/16 v4, -0x3050

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->writeShort(S)V

    .line 588
    :try_start_0
    invoke-direct {p0, v2}, Lcom/motorola/android/locationproxy/Supl;->send(Lcom/motorola/android/locationproxy/SuplRequest;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 592
    :goto_1
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    goto :goto_0

    .line 589
    :catch_0
    move-exception v0

    .line 590
    .local v0, ex:Ljava/io/IOException;
    const/4 v4, 0x2

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->onError(I)V

    goto :goto_1
.end method

.method public sendOpenSocketResult(III)V
    .locals 8
    .parameter "id"
    .parameter "linkId"
    .parameter "result"

    .prologue
    .line 431
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->findAndRemoveRequestFromList(I)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v3

    .line 432
    .local v3, req:Lcom/motorola/android/locationproxy/SuplRequest;
    if-nez v3, :cond_0

    .line 433
    const-string v4, "SUPLJ"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "Invalid ID: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 462
    :goto_0
    return-void

    .line 437
    :cond_0
    const/16 v4, 0xa

    iget-byte v5, v3, Lcom/motorola/android/locationproxy/SuplRequest;->mSessionId:B

    iget-byte v6, v3, Lcom/motorola/android/locationproxy/SuplRequest;->mTransactionId:B

    const/4 v7, 0x0

    invoke-static {v4, v5, v6, v7}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v2

    .line 441
    .local v2, r:Lcom/motorola/android/locationproxy/SuplRequest;
    invoke-virtual {v3}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 448
    sget v4, Lcom/motorola/android/locationproxy/SuplRequest;->sHeaderLength:I

    add-int/lit8 v4, v4, 0x4

    add-int/lit8 v4, v4, 0x4

    sget v5, Lcom/motorola/android/locationproxy/SuplRequest;->sTailLength:I

    add-int v1, v4, v5

    .line 449
    .local v1, length:I
    invoke-virtual {v2, v1}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataCapacity(I)V

    .line 450
    const/4 v4, 0x0

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataPosition(I)V

    .line 451
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeHeader()V

    .line 452
    invoke-virtual {v2, p2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 453
    invoke-virtual {v2, p3}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 454
    const/16 v4, -0x3050

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->writeShort(S)V

    .line 457
    :try_start_0
    invoke-direct {p0, v2}, Lcom/motorola/android/locationproxy/Supl;->send(Lcom/motorola/android/locationproxy/SuplRequest;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 461
    :goto_1
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    goto :goto_0

    .line 458
    :catch_0
    move-exception v0

    .line 459
    .local v0, ex:Ljava/io/IOException;
    const/4 v4, 0x2

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->onError(I)V

    goto :goto_1
.end method

.method public sendSocketDataResult(III)V
    .locals 8
    .parameter "id"
    .parameter "linkId"
    .parameter "result"

    .prologue
    .line 499
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->findAndRemoveRequestFromList(I)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v3

    .line 500
    .local v3, req:Lcom/motorola/android/locationproxy/SuplRequest;
    if-nez v3, :cond_0

    .line 501
    const-string v4, "SUPLJ"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "Invalid ID: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 528
    :goto_0
    return-void

    .line 505
    :cond_0
    const/16 v4, 0xc

    iget-byte v5, v3, Lcom/motorola/android/locationproxy/SuplRequest;->mSessionId:B

    iget-byte v6, v3, Lcom/motorola/android/locationproxy/SuplRequest;->mTransactionId:B

    const/4 v7, 0x0

    invoke-static {v4, v5, v6, v7}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v2

    .line 509
    .local v2, r:Lcom/motorola/android/locationproxy/SuplRequest;
    invoke-virtual {v3}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 515
    sget v4, Lcom/motorola/android/locationproxy/SuplRequest;->sHeaderLength:I

    add-int/lit8 v4, v4, 0x4

    add-int/lit8 v4, v4, 0x4

    sget v5, Lcom/motorola/android/locationproxy/SuplRequest;->sTailLength:I

    add-int v1, v4, v5

    .line 516
    .local v1, length:I
    invoke-virtual {v2, v1}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataCapacity(I)V

    .line 517
    const/4 v4, 0x0

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataPosition(I)V

    .line 518
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeHeader()V

    .line 519
    invoke-virtual {v2, p2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 520
    invoke-virtual {v2, p3}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 521
    const/16 v4, -0x3050

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->writeShort(S)V

    .line 523
    :try_start_0
    invoke-direct {p0, v2}, Lcom/motorola/android/locationproxy/Supl;->send(Lcom/motorola/android/locationproxy/SuplRequest;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 527
    :goto_1
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    goto :goto_0

    .line 524
    :catch_0
    move-exception v0

    .line 525
    .local v0, ex:Ljava/io/IOException;
    const/4 v4, 0x2

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->onError(I)V

    goto :goto_1
.end method

.method public sendTlsResult(IIB)V
    .locals 8
    .parameter "id"
    .parameter "linkId"
    .parameter "tls_result"

    .prologue
    .line 596
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/Supl;->findAndRemoveRequestFromList(I)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v3

    .line 597
    .local v3, req:Lcom/motorola/android/locationproxy/SuplRequest;
    if-nez v3, :cond_0

    .line 598
    const-string v4, "SUPLJ"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "Invalid ID: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v4, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 627
    :goto_0
    return-void

    .line 602
    :cond_0
    const/16 v4, 0x1f

    iget-byte v5, v3, Lcom/motorola/android/locationproxy/SuplRequest;->mSessionId:B

    iget-byte v6, v3, Lcom/motorola/android/locationproxy/SuplRequest;->mTransactionId:B

    const/4 v7, 0x0

    invoke-static {v4, v5, v6, v7}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v2

    .line 606
    .local v2, r:Lcom/motorola/android/locationproxy/SuplRequest;
    invoke-virtual {v3}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 612
    sget v4, Lcom/motorola/android/locationproxy/SuplRequest;->sHeaderLength:I

    add-int/lit8 v4, v4, 0x4

    add-int/lit8 v4, v4, 0x1

    sget v5, Lcom/motorola/android/locationproxy/SuplRequest;->sTailLength:I

    add-int v1, v4, v5

    .line 613
    .local v1, length:I
    invoke-virtual {v2, v1}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataCapacity(I)V

    .line 614
    const/4 v4, 0x0

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataPosition(I)V

    .line 616
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeHeader()V

    .line 617
    invoke-virtual {v2, p2}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 618
    invoke-virtual {v2, p3}, Lcom/motorola/android/locationproxy/SuplRequest;->writeByte(B)V

    .line 619
    const/16 v4, -0x3050

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->writeShort(S)V

    .line 622
    :try_start_0
    invoke-direct {p0, v2}, Lcom/motorola/android/locationproxy/Supl;->send(Lcom/motorola/android/locationproxy/SuplRequest;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 626
    :goto_1
    invoke-virtual {v2}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    goto :goto_0

    .line 623
    :catch_0
    move-exception v0

    .line 624
    .local v0, ex:Ljava/io/IOException;
    const/4 v4, 0x2

    invoke-virtual {v2, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->onError(I)V

    goto :goto_1
.end method

.method public sendWapPushNotification([B)V
    .locals 7
    .parameter "data"

    .prologue
    const/4 v6, 0x0

    .line 630
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "Forward wap push data "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    array-length v5, p1

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "bytes"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-direct {p0, v4}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 631
    invoke-static {p1}, Lcom/motorola/android/locationproxy/Supl;->logHexData([B)V

    .line 633
    const/16 v4, 0x10

    const/4 v5, 0x0

    invoke-static {v4, v6, v6, v5}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v3

    .line 637
    .local v3, r:Lcom/motorola/android/locationproxy/SuplRequest;
    array-length v0, p1

    .line 644
    .local v0, dataLength:I
    sget v4, Lcom/motorola/android/locationproxy/SuplRequest;->sHeaderLength:I

    add-int/lit8 v4, v4, 0x4

    add-int/2addr v4, v0

    sget v5, Lcom/motorola/android/locationproxy/SuplRequest;->sTailLength:I

    add-int v2, v4, v5

    .line 645
    .local v2, length:I
    invoke-virtual {v3, v2}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataCapacity(I)V

    .line 646
    invoke-virtual {v3, v6}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataPosition(I)V

    .line 648
    invoke-virtual {v3}, Lcom/motorola/android/locationproxy/SuplRequest;->writeHeader()V

    .line 649
    invoke-virtual {v3, v0}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 650
    invoke-virtual {v3, p1}, Lcom/motorola/android/locationproxy/SuplRequest;->writeByteArray([B)V

    .line 651
    const/16 v4, -0x3050

    invoke-virtual {v3, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->writeShort(S)V

    .line 653
    :try_start_0
    invoke-direct {p0, v3}, Lcom/motorola/android/locationproxy/Supl;->send(Lcom/motorola/android/locationproxy/SuplRequest;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 657
    :goto_0
    invoke-virtual {v3}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 658
    return-void

    .line 654
    :catch_0
    move-exception v1

    .line 655
    .local v1, ex:Ljava/io/IOException;
    const/4 v4, 0x2

    invoke-virtual {v3, v4}, Lcom/motorola/android/locationproxy/SuplRequest;->onError(I)V

    goto :goto_0
.end method

.method public setUserConfigFQDN(Ljava/lang/String;)Z
    .locals 10
    .parameter "newFQDN"

    .prologue
    const/4 v9, 0x0

    .line 771
    invoke-static {}, Landroid/os/Message;->obtain()Landroid/os/Message;

    move-result-object v5

    .line 772
    .local v5, result:Landroid/os/Message;
    const/4 v6, 0x4

    invoke-direct {p0}, Lcom/motorola/android/locationproxy/Supl;->generateSessionID()B

    move-result v7

    invoke-direct {p0}, Lcom/motorola/android/locationproxy/Supl;->generateTransactionId()B

    move-result v8

    invoke-static {v6, v7, v8, v5}, Lcom/motorola/android/locationproxy/SuplRequest;->obtain(BBBLandroid/os/Message;)Lcom/motorola/android/locationproxy/SuplRequest;

    move-result-object v4

    .line 777
    .local v4, r:Lcom/motorola/android/locationproxy/SuplRequest;
    invoke-virtual {p1}, Ljava/lang/String;->getBytes()[B

    move-result-object v0

    .line 778
    .local v0, data:[B
    array-length v6, v0

    add-int/lit8 v1, v6, 0x1

    .line 785
    .local v1, dataLength:I
    sget v6, Lcom/motorola/android/locationproxy/SuplRequest;->sHeaderLength:I

    add-int/lit8 v6, v6, 0x2

    add-int/lit8 v6, v6, 0x4

    add-int/lit8 v6, v6, 0x2

    add-int/2addr v6, v1

    sget v7, Lcom/motorola/android/locationproxy/SuplRequest;->sTailLength:I

    add-int v3, v6, v7

    .line 786
    .local v3, length:I
    invoke-virtual {v4, v3}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataCapacity(I)V

    .line 787
    invoke-virtual {v4, v9}, Lcom/motorola/android/locationproxy/SuplRequest;->setDataPosition(I)V

    .line 789
    invoke-virtual {v4}, Lcom/motorola/android/locationproxy/SuplRequest;->writeHeader()V

    .line 790
    const/4 v6, 0x1

    invoke-virtual {v4, v6}, Lcom/motorola/android/locationproxy/SuplRequest;->writeShort(S)V

    .line 791
    const/high16 v6, 0x4

    invoke-virtual {v4, v6}, Lcom/motorola/android/locationproxy/SuplRequest;->writeInt(I)V

    .line 792
    int-to-short v6, v1

    invoke-virtual {v4, v6}, Lcom/motorola/android/locationproxy/SuplRequest;->writeShort(S)V

    .line 793
    invoke-virtual {v4, v0}, Lcom/motorola/android/locationproxy/SuplRequest;->writeByteArray([B)V

    .line 794
    invoke-virtual {v4, v9}, Lcom/motorola/android/locationproxy/SuplRequest;->writeByte(B)V

    .line 795
    const/16 v6, -0x3050

    invoke-virtual {v4, v6}, Lcom/motorola/android/locationproxy/SuplRequest;->writeShort(S)V

    .line 797
    iput-boolean v9, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnWriteResult:Z

    .line 799
    sget-object v6, Lcom/motorola/android/locationproxy/Supl;->sFqdnWriteLock:Ljava/lang/Object;

    monitor-enter v6

    .line 800
    :try_start_0
    iget-object v7, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    monitor-enter v7
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    .line 802
    :try_start_1
    invoke-direct {p0, v4}, Lcom/motorola/android/locationproxy/Supl;->send(Lcom/motorola/android/locationproxy/SuplRequest;)V

    .line 803
    iget-object v8, p0, Lcom/motorola/android/locationproxy/Supl;->mRequestsList:Ljava/util/ArrayList;

    invoke-virtual {v8, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_0

    .line 809
    :try_start_2
    monitor-exit v7
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 811
    :try_start_3
    const-string v7, "*** calling sFqdnWriteLock.wait()"

    invoke-direct {p0, v7}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V

    .line 812
    sget-object v7, Lcom/motorola/android/locationproxy/Supl;->sFqdnWriteLock:Ljava/lang/Object;

    invoke-virtual {v7}, Ljava/lang/Object;->wait()V

    .line 813
    const-string v7, "*** finish sFqdnWriteLock.wait()"

    invoke-direct {p0, v7}, Lcom/motorola/android/locationproxy/Supl;->suplLog(Ljava/lang/String;)V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1
    .catch Ljava/lang/InterruptedException; {:try_start_3 .. :try_end_3} :catch_1

    .line 820
    :try_start_4
    monitor-exit v6
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_1

    .line 822
    invoke-virtual {v4}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 823
    invoke-virtual {v5}, Landroid/os/Message;->recycle()V

    .line 824
    iget-boolean v6, p0, Lcom/motorola/android/locationproxy/Supl;->mFqdnWriteResult:Z

    :goto_0
    return v6

    .line 804
    :catch_0
    move-exception v8

    move-object v2, v8

    .line 805
    .local v2, ex:Ljava/io/IOException;
    :try_start_5
    invoke-virtual {v4}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 806
    invoke-virtual {v5}, Landroid/os/Message;->recycle()V

    .line 807
    monitor-exit v7
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_0

    :try_start_6
    monitor-exit v6
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_1

    move v6, v9

    goto :goto_0

    .line 809
    .end local v2           #ex:Ljava/io/IOException;
    :catchall_0
    move-exception v8

    :try_start_7
    monitor-exit v7
    :try_end_7
    .catchall {:try_start_7 .. :try_end_7} :catchall_0

    :try_start_8
    throw v8

    .line 820
    :catchall_1
    move-exception v7

    monitor-exit v6
    :try_end_8
    .catchall {:try_start_8 .. :try_end_8} :catchall_1

    throw v7

    .line 814
    :catch_1
    move-exception v7

    move-object v2, v7

    .line 815
    .local v2, ex:Ljava/lang/InterruptedException;
    :try_start_9
    const-string v7, "SUPLJ"

    const-string v8, "got InterruptedException!"

    invoke-static {v7, v8}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 816
    invoke-virtual {v4}, Lcom/motorola/android/locationproxy/SuplRequest;->release()V

    .line 817
    invoke-virtual {v5}, Landroid/os/Message;->recycle()V

    .line 818
    monitor-exit v6
    :try_end_9
    .catchall {:try_start_9 .. :try_end_9} :catchall_1

    move v6, v9

    goto :goto_0
.end method
