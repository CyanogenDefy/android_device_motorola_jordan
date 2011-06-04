.class Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;
.super Ljava/lang/Object;
.source "SuplDataService.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/motorola/android/locationproxy/SuplDataService;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x2
    name = "PlainTextWorkerThread"
.end annotation


# instance fields
.field final synthetic this$0:Lcom/motorola/android/locationproxy/SuplDataService;


# direct methods
.method private constructor <init>(Lcom/motorola/android/locationproxy/SuplDataService;)V
    .locals 0
    .parameter

    .prologue
    .line 380
    iput-object p1, p0, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;->this$0:Lcom/motorola/android/locationproxy/SuplDataService;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method synthetic constructor <init>(Lcom/motorola/android/locationproxy/SuplDataService;Lcom/motorola/android/locationproxy/SuplDataService$1;)V
    .locals 0
    .parameter "x0"
    .parameter "x1"

    .prologue
    .line 380
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;-><init>(Lcom/motorola/android/locationproxy/SuplDataService;)V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 10

    .prologue
    const/4 v9, 0x0

    const-string v8, "SUPLJ"

    .line 383
    :try_start_0
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;->this$0:Lcom/motorola/android/locationproxy/SuplDataService;

    invoke-static {v5}, Lcom/motorola/android/locationproxy/SuplDataService;->access$400(Lcom/motorola/android/locationproxy/SuplDataService;)Ljava/nio/channels/SocketChannel;

    move-result-object v5

    iget-object v6, p0, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;->this$0:Lcom/motorola/android/locationproxy/SuplDataService;

    invoke-static {v6}, Lcom/motorola/android/locationproxy/SuplDataService;->access$300(Lcom/motorola/android/locationproxy/SuplDataService;)Ljava/nio/channels/Selector;

    move-result-object v6

    const/4 v7, 0x1

    invoke-virtual {v5, v6, v7}, Ljava/nio/channels/SocketChannel;->register(Ljava/nio/channels/Selector;I)Ljava/nio/channels/SelectionKey;

    .line 384
    :goto_0
    invoke-static {}, Ljava/lang/Thread;->interrupted()Z

    move-result v5

    if-nez v5, :cond_2

    .line 385
    :cond_0
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;->this$0:Lcom/motorola/android/locationproxy/SuplDataService;

    invoke-static {v5}, Lcom/motorola/android/locationproxy/SuplDataService;->access$300(Lcom/motorola/android/locationproxy/SuplDataService;)Ljava/nio/channels/Selector;

    move-result-object v5

    invoke-virtual {v5}, Ljava/nio/channels/Selector;->select()I

    move-result v5

    if-lez v5, :cond_1

    .line 386
    const-string v5, "SUPLJ"

    const-string v6, "Select() returned!!"

    invoke-static {v5, v6}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 387
    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/Thread;->isInterrupted()Z

    move-result v5

    if-eqz v5, :cond_3

    .line 388
    const-string v5, "SUPLJ"

    const-string v6, "Thread interrputed, will ignore all unread data."

    invoke-static {v5, v6}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 409
    :cond_1
    const-string v5, "SUPLJ"

    const-string v6, "Selector.select() returned non-positive value"

    invoke-static {v5, v6}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 411
    :catch_0
    move-exception v5

    move-object v0, v5

    .line 412
    .local v0, e:Ljava/lang/Exception;
    invoke-virtual {v0}, Ljava/lang/Exception;->printStackTrace()V

    .line 413
    const-string v5, "SUPLJ"

    invoke-virtual {v0}, Ljava/lang/Exception;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v8, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 414
    new-array v1, v9, [B

    .line 415
    .local v1, emptyData:[B
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;->this$0:Lcom/motorola/android/locationproxy/SuplDataService;

    invoke-static {v5}, Lcom/motorola/android/locationproxy/SuplDataService;->access$600(Lcom/motorola/android/locationproxy/SuplDataService;)Lcom/motorola/android/locationproxy/ISuplCommands;

    move-result-object v5

    const/4 v6, -0x1

    invoke-interface {v5, v9, v1, v6}, Lcom/motorola/android/locationproxy/ISuplCommands;->forwardSocketData(I[BI)V

    .line 416
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;->this$0:Lcom/motorola/android/locationproxy/SuplDataService;

    invoke-virtual {v5}, Lcom/motorola/android/locationproxy/SuplDataService;->close()V

    .line 418
    .end local v0           #e:Ljava/lang/Exception;
    .end local v1           #emptyData:[B
    :cond_2
    const-string v5, "SUPLJ"

    const-string v5, "Exiting PlaintextWorkerThread..."

    invoke-static {v8, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 419
    return-void

    .line 391
    :cond_3
    :try_start_1
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;->this$0:Lcom/motorola/android/locationproxy/SuplDataService;

    invoke-static {v5}, Lcom/motorola/android/locationproxy/SuplDataService;->access$300(Lcom/motorola/android/locationproxy/SuplDataService;)Ljava/nio/channels/Selector;

    move-result-object v5

    invoke-virtual {v5}, Ljava/nio/channels/Selector;->selectedKeys()Ljava/util/Set;

    move-result-object v5

    invoke-interface {v5}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v2

    .line 392
    .local v2, it:Ljava/util/Iterator;,"Ljava/util/Iterator<Ljava/nio/channels/SelectionKey;>;"
    :cond_4
    :goto_1
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_0

    .line 393
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/nio/channels/SelectionKey;

    .line 394
    .local v3, key:Ljava/nio/channels/SelectionKey;
    invoke-virtual {v3}, Ljava/nio/channels/SelectionKey;->readyOps()I

    move-result v5

    and-int/lit8 v5, v5, 0x1

    if-eqz v5, :cond_4

    .line 395
    const-string v5, "SUPLJ"

    const-string v6, "Got data from server."

    invoke-static {v5, v6}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 396
    invoke-virtual {v3}, Ljava/nio/channels/SelectionKey;->channel()Ljava/nio/channels/SelectableChannel;

    move-result-object v4

    check-cast v4, Ljava/nio/channels/SocketChannel;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0

    .line 398
    .local v4, keyChannel:Ljava/nio/channels/SocketChannel;
    :try_start_2
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;->this$0:Lcom/motorola/android/locationproxy/SuplDataService;

    invoke-static {v5}, Lcom/motorola/android/locationproxy/SuplDataService;->access$500(Lcom/motorola/android/locationproxy/SuplDataService;)Lcom/motorola/android/locationproxy/SuplDataService$DataHandler;

    move-result-object v5

    invoke-virtual {v5, v4}, Lcom/motorola/android/locationproxy/SuplDataService$DataHandler;->handleIncomingData(Ljava/nio/channels/SocketChannel;)V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_1
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0

    .line 405
    :try_start_3
    invoke-interface {v2}, Ljava/util/Iterator;->remove()V

    goto :goto_1

    .line 399
    :catch_1
    move-exception v5

    move-object v0, v5

    .line 400
    .local v0, e:Ljava/io/IOException;
    invoke-virtual {v0}, Ljava/io/IOException;->printStackTrace()V

    .line 402
    invoke-virtual {v3}, Ljava/nio/channels/SelectionKey;->cancel()V

    .line 403
    throw v0
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_0
.end method
