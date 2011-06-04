.class public Lcom/motorola/android/locationproxy/SuplDataService;
.super Landroid/os/Handler;
.source "SuplDataService.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/motorola/android/locationproxy/SuplDataService$3;,
        Lcom/motorola/android/locationproxy/SuplDataService$DataHandler;,
        Lcom/motorola/android/locationproxy/SuplDataService$SslWorkerThread;,
        Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;
    }
.end annotation


# static fields
.field private static final ADDRESSTYPE_DNS:I = 0x1

.field private static final ADDRESSTYPE_IP:I = 0x0

.field private static final CERT_PASS:Ljava/lang/String; = "ClientKey"

.field private static final CONNECTION_TIMEOUT:I = 0x7530

.field private static final FTOUTPUT_TAG:Ljava/lang/String; = "FTOUTPUT"

.field private static final KEY_STORE:Ljava/lang/String; = "/data/client.bks"

.field private static final KEY_STORE_PASS:Ljava/lang/String; = "ClientBKS"

.field private static final TAG:Ljava/lang/String; = "SUPLJ"


# instance fields
.field private final DEBUG:Z

.field private final USE_LOCAL_KEYSTORE:Z

.field private _host:Ljava/lang/String;

.field private _port:I

.field private mDataHandler:Lcom/motorola/android/locationproxy/SuplDataService$DataHandler;

.field private mHost:Ljava/lang/String;

.field private mIsClosing:Z

.field private mIsTlsMode:Z

.field private mKeyMgrFactory:Ljavax/net/ssl/KeyManagerFactory;

.field private mPort:S

.field private mSelector:Ljava/nio/channels/Selector;

.field private mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

.field private mSocketChannel:Ljava/nio/channels/SocketChannel;

.field private mSslContext:Ljavax/net/ssl/SSLContext;

.field private mSslSocket:Ljavax/net/ssl/SSLSocket;

.field private mTrustManager:Lcom/motorola/android/locationproxy/SuplTrustManager;

.field private mWorkerThread:Ljava/lang/Thread;


# direct methods
.method public constructor <init>(Lcom/motorola/android/locationproxy/ISuplCommands;)V
    .locals 3
    .parameter "shimProxy"

    .prologue
    const/4 v2, 0x0

    const/4 v1, 0x0

    .line 83
    invoke-direct {p0}, Landroid/os/Handler;-><init>()V

    .line 46
    iput-boolean v2, p0, Lcom/motorola/android/locationproxy/SuplDataService;->DEBUG:Z

    .line 47
    iput-boolean v2, p0, Lcom/motorola/android/locationproxy/SuplDataService;->USE_LOCAL_KEYSTORE:Z

    .line 57
    iput-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSelector:Ljava/nio/channels/Selector;

    .line 58
    iput-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    .line 59
    iput-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mHost:Ljava/lang/String;

    .line 60
    const/4 v0, -0x1

    iput-short v0, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mPort:S

    .line 62
    iput-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    .line 69
    iput-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSslContext:Ljavax/net/ssl/SSLContext;

    .line 70
    iput-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mKeyMgrFactory:Ljavax/net/ssl/KeyManagerFactory;

    .line 71
    iput-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSslSocket:Ljavax/net/ssl/SSLSocket;

    .line 72
    iput-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mTrustManager:Lcom/motorola/android/locationproxy/SuplTrustManager;

    .line 74
    new-instance v0, Lcom/motorola/android/locationproxy/SuplDataService$DataHandler;

    invoke-direct {v0, p0, v1}, Lcom/motorola/android/locationproxy/SuplDataService$DataHandler;-><init>(Lcom/motorola/android/locationproxy/SuplDataService;Lcom/motorola/android/locationproxy/SuplDataService$1;)V

    iput-object v0, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mDataHandler:Lcom/motorola/android/locationproxy/SuplDataService$DataHandler;

    .line 76
    iput-boolean v2, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mIsTlsMode:Z

    .line 77
    iput-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    .line 78
    iput-boolean v2, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mIsClosing:Z

    .line 80
    const-string v0, "10.0.2.2"

    iput-object v0, p0, Lcom/motorola/android/locationproxy/SuplDataService;->_host:Ljava/lang/String;

    .line 81
    const/16 v0, 0x22b8

    iput v0, p0, Lcom/motorola/android/locationproxy/SuplDataService;->_port:I

    .line 84
    iput-object p1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    .line 85
    const/16 v0, 0xf

    invoke-interface {p1, p0, v0, v1}, Lcom/motorola/android/locationproxy/ISuplCommands;->registerForSuplRequest(Landroid/os/Handler;ILjava/lang/Object;)V

    .line 88
    return-void
.end method

.method static synthetic access$1000(Lcom/motorola/android/locationproxy/SuplDataService;Ljava/nio/ByteBuffer;)V
    .locals 0
    .parameter "x0"
    .parameter "x1"
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 44
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/SuplDataService;->flush(Ljava/nio/ByteBuffer;)V

    return-void
.end method

.method static synthetic access$300(Lcom/motorola/android/locationproxy/SuplDataService;)Ljava/nio/channels/Selector;
    .locals 1
    .parameter "x0"

    .prologue
    .line 44
    iget-object v0, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSelector:Ljava/nio/channels/Selector;

    return-object v0
.end method

.method static synthetic access$400(Lcom/motorola/android/locationproxy/SuplDataService;)Ljava/nio/channels/SocketChannel;
    .locals 1
    .parameter "x0"

    .prologue
    .line 44
    iget-object v0, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    return-object v0
.end method

.method static synthetic access$500(Lcom/motorola/android/locationproxy/SuplDataService;)Lcom/motorola/android/locationproxy/SuplDataService$DataHandler;
    .locals 1
    .parameter "x0"

    .prologue
    .line 44
    iget-object v0, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mDataHandler:Lcom/motorola/android/locationproxy/SuplDataService$DataHandler;

    return-object v0
.end method

.method static synthetic access$600(Lcom/motorola/android/locationproxy/SuplDataService;)Lcom/motorola/android/locationproxy/ISuplCommands;
    .locals 1
    .parameter "x0"

    .prologue
    .line 44
    iget-object v0, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    return-object v0
.end method

.method static synthetic access$700(Lcom/motorola/android/locationproxy/SuplDataService;)Ljavax/net/ssl/SSLSocket;
    .locals 1
    .parameter "x0"

    .prologue
    .line 44
    iget-object v0, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSslSocket:Ljavax/net/ssl/SSLSocket;

    return-object v0
.end method

.method static synthetic access$800(Lcom/motorola/android/locationproxy/SuplDataService;Ljava/nio/ByteBuffer;)[B
    .locals 1
    .parameter "x0"
    .parameter "x1"

    .prologue
    .line 44
    invoke-direct {p0, p1}, Lcom/motorola/android/locationproxy/SuplDataService;->byteBuffer2ByteArray(Ljava/nio/ByteBuffer;)[B

    move-result-object v0

    return-object v0
.end method

.method static synthetic access$900(Lcom/motorola/android/locationproxy/SuplDataService;)Z
    .locals 1
    .parameter "x0"

    .prologue
    .line 44
    iget-boolean v0, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mIsClosing:Z

    return v0
.end method

.method private byteBuffer2ByteArray(Ljava/nio/ByteBuffer;)[B
    .locals 2
    .parameter "buffer"

    .prologue
    .line 496
    invoke-virtual {p1}, Ljava/nio/ByteBuffer;->limit()I

    move-result v1

    new-array v0, v1, [B

    .line 497
    .local v0, b:[B
    invoke-virtual {p1, v0}, Ljava/nio/ByteBuffer;->get([B)Ljava/nio/ByteBuffer;

    .line 498
    return-object v0
.end method

.method private flush(Ljava/nio/ByteBuffer;)V
    .locals 4
    .parameter "buffer"
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 461
    :goto_0
    invoke-virtual {p1}, Ljava/nio/ByteBuffer;->hasRemaining()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 462
    iget-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    invoke-virtual {v1, p1}, Ljava/nio/channels/SocketChannel;->write(Ljava/nio/ByteBuffer;)I

    move-result v0

    .line 463
    .local v0, bytesWrote:I
    const-string v1, "SUPLJ"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "Bytes written: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 465
    .end local v0           #bytesWrote:I
    :cond_0
    return-void
.end method

.method private initKeyManagers()V
    .locals 10
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/security/GeneralSecurityException;,
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    const/4 v8, 0x0

    const-string v9, "javax.net.ssl.trustStore"

    const-string v7, "SUPLJ"

    .line 297
    const/4 v5, 0x0

    new-array v4, v5, [C

    .line 299
    .local v4, pwd:[C
    const-string v5, "javax.net.ssl.trustStore"

    invoke-static {v9}, Ljava/lang/System;->getProperty(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    if-nez v5, :cond_0

    .line 300
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "java.home"

    invoke-static {v6}, Ljava/lang/System;->getProperty(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget-object v6, Ljava/io/File;->separator:Ljava/lang/String;

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, "etc"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget-object v6, Ljava/io/File;->separator:Ljava/lang/String;

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, "security"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    sget-object v6, Ljava/io/File;->separator:Ljava/lang/String;

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, "cacerts.bks"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 304
    .local v0, file:Ljava/lang/String;
    const-string v5, "SUPLJ"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "file = "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v7, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 305
    const-string v5, "javax.net.ssl.trustStore"

    invoke-static {v9, v0}, Ljava/lang/System;->setProperty(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    .line 308
    .end local v0           #file:Ljava/lang/String;
    :cond_0
    invoke-static {}, Ljava/security/KeyStore;->getDefaultType()Ljava/lang/String;

    move-result-object v5

    invoke-static {v5}, Ljava/security/KeyStore;->getInstance(Ljava/lang/String;)Ljava/security/KeyStore;

    move-result-object v1

    .line 309
    .local v1, keyStore:Ljava/security/KeyStore;
    new-instance v5, Lcom/motorola/android/locationproxy/SuplDataService$1;

    invoke-direct {v5, p0}, Lcom/motorola/android/locationproxy/SuplDataService$1;-><init>(Lcom/motorola/android/locationproxy/SuplDataService;)V

    invoke-static {v5}, Ljava/security/AccessController;->doPrivileged(Ljava/security/PrivilegedAction;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    .line 317
    .local v2, keyStoreName:Ljava/lang/String;
    const/4 v3, 0x0

    .line 318
    .local v3, keyStorePwd:Ljava/lang/String;
    if-eqz v2, :cond_1

    const-string v5, "NONE"

    invoke-virtual {v2, v5}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z

    move-result v5

    if-nez v5, :cond_1

    invoke-virtual {v2}, Ljava/lang/String;->length()I

    move-result v5

    if-nez v5, :cond_2

    .line 320
    :cond_1
    const-string v5, "SUPLJ"

    const-string v5, "No Keystore"

    invoke-static {v7, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 321
    invoke-virtual {v1, v8, v8}, Ljava/security/KeyStore;->load(Ljava/io/InputStream;[C)V

    .line 343
    :goto_0
    invoke-static {}, Ljavax/net/ssl/KeyManagerFactory;->getDefaultAlgorithm()Ljava/lang/String;

    move-result-object v5

    invoke-static {v5}, Ljavax/net/ssl/KeyManagerFactory;->getInstance(Ljava/lang/String;)Ljavax/net/ssl/KeyManagerFactory;

    move-result-object v5

    iput-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mKeyMgrFactory:Ljavax/net/ssl/KeyManagerFactory;

    .line 344
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mKeyMgrFactory:Ljavax/net/ssl/KeyManagerFactory;

    invoke-virtual {v5, v1, v4}, Ljavax/net/ssl/KeyManagerFactory;->init(Ljava/security/KeyStore;[C)V

    .line 347
    new-instance v5, Lcom/motorola/android/locationproxy/SuplTrustManager;

    invoke-direct {v5, v1}, Lcom/motorola/android/locationproxy/SuplTrustManager;-><init>(Ljava/security/KeyStore;)V

    iput-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mTrustManager:Lcom/motorola/android/locationproxy/SuplTrustManager;

    .line 348
    return-void

    .line 323
    :cond_2
    new-instance v5, Lcom/motorola/android/locationproxy/SuplDataService$2;

    invoke-direct {v5, p0}, Lcom/motorola/android/locationproxy/SuplDataService$2;-><init>(Lcom/motorola/android/locationproxy/SuplDataService;)V

    invoke-static {v5}, Ljava/security/AccessController;->doPrivileged(Ljava/security/PrivilegedAction;)Ljava/lang/Object;

    move-result-object v3

    .end local v3           #keyStorePwd:Ljava/lang/String;
    check-cast v3, Ljava/lang/String;

    .line 330
    .restart local v3       #keyStorePwd:Ljava/lang/String;
    const-string v5, "SUPLJ"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "keyStorePwd = "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v7, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 331
    if-eqz v3, :cond_3

    .line 332
    invoke-virtual {v3}, Ljava/lang/String;->toCharArray()[C

    move-result-object v4

    .line 334
    :cond_3
    new-instance v5, Ljava/io/FileInputStream;

    new-instance v6, Ljava/io/File;

    invoke-direct {v6, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-direct {v5, v6}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    invoke-virtual {v1, v5, v4}, Ljava/security/KeyStore;->load(Ljava/io/InputStream;[C)V

    goto :goto_0
.end method

.method private initSslSocket(Ljava/lang/String;I)V
    .locals 6
    .parameter "host"
    .parameter "port"
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/security/GeneralSecurityException;,
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    const/4 v5, 0x1

    .line 351
    const-string v2, "TLS"

    invoke-static {v2}, Ljavax/net/ssl/SSLContext;->getInstance(Ljava/lang/String;)Ljavax/net/ssl/SSLContext;

    move-result-object v2

    iput-object v2, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSslContext:Ljavax/net/ssl/SSLContext;

    .line 353
    new-array v0, v5, [Ljavax/net/ssl/TrustManager;

    .line 354
    .local v0, mgrs:[Ljavax/net/ssl/TrustManager;
    const/4 v2, 0x0

    iget-object v3, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mTrustManager:Lcom/motorola/android/locationproxy/SuplTrustManager;

    aput-object v3, v0, v2

    .line 355
    iget-object v2, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSslContext:Ljavax/net/ssl/SSLContext;

    iget-object v3, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mKeyMgrFactory:Ljavax/net/ssl/KeyManagerFactory;

    invoke-virtual {v3}, Ljavax/net/ssl/KeyManagerFactory;->getKeyManagers()[Ljavax/net/ssl/KeyManager;

    move-result-object v3

    const/4 v4, 0x0

    invoke-virtual {v2, v3, v0, v4}, Ljavax/net/ssl/SSLContext;->init([Ljavax/net/ssl/KeyManager;[Ljavax/net/ssl/TrustManager;Ljava/security/SecureRandom;)V

    .line 356
    iget-object v2, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSslContext:Ljavax/net/ssl/SSLContext;

    invoke-virtual {v2}, Ljavax/net/ssl/SSLContext;->getSocketFactory()Ljavax/net/ssl/SSLSocketFactory;

    move-result-object v1

    .line 357
    .local v1, ssf:Ljavax/net/ssl/SSLSocketFactory;
    iget-object v2, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    invoke-virtual {v2}, Ljava/nio/channels/SocketChannel;->socket()Ljava/net/Socket;

    move-result-object v2

    invoke-virtual {v1, v2, p1, p2, v5}, Ljavax/net/ssl/SSLSocketFactory;->createSocket(Ljava/net/Socket;Ljava/lang/String;IZ)Ljava/net/Socket;

    move-result-object v2

    check-cast v2, Ljavax/net/ssl/SSLSocket;

    iput-object v2, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSslSocket:Ljavax/net/ssl/SSLSocket;

    .line 358
    iget-object v2, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSslSocket:Ljavax/net/ssl/SSLSocket;

    invoke-virtual {v2}, Ljavax/net/ssl/SSLSocket;->startHandshake()V

    .line 359
    const-string v2, "FTOUTPUT"

    const-string v3, "Handshake completed."

    invoke-static {v2, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 360
    return-void
.end method

.method private static intToIp(I)Ljava/lang/String;
    .locals 3
    .parameter "i"

    .prologue
    const-string v2, "."

    .line 502
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    shr-int/lit8 v1, p0, 0x18

    and-int/lit16 v1, v1, 0xff

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "."

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    shr-int/lit8 v1, p0, 0x10

    and-int/lit16 v1, v1, 0xff

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "."

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    shr-int/lit8 v1, p0, 0x8

    and-int/lit16 v1, v1, 0xff

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "."

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    and-int/lit16 v1, p0, 0xff

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method private static msg2ObjArray(Landroid/os/Message;)[Ljava/lang/Object;
    .locals 1
    .parameter "msg"

    .prologue
    .line 507
    iget-object v0, p0, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v0, Landroid/os/AsyncResult;

    .line 508
    .local v0, ar:Landroid/os/AsyncResult;
    iget-object p0, v0, Landroid/os/AsyncResult;->result:Ljava/lang/Object;

    .end local p0
    check-cast p0, [Ljava/lang/Object;

    check-cast p0, [Ljava/lang/Object;

    return-object p0
.end method

.method private openPlainTextConnection(Ljava/lang/String;I)V
    .locals 9
    .parameter "host"
    .parameter "port"
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    const-string v8, "SUPLJ"

    .line 247
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    if-eqz v5, :cond_0

    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    invoke-virtual {v5}, Ljava/nio/channels/SocketChannel;->isOpen()Z

    move-result v5

    if-nez v5, :cond_1

    .line 248
    :cond_0
    const-string v5, "SUPLJ"

    const-string v5, "Opening SocketChannel..."

    invoke-static {v8, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 249
    invoke-static {}, Ljava/nio/channels/SocketChannel;->open()Ljava/nio/channels/SocketChannel;

    move-result-object v5

    iput-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    .line 252
    :cond_1
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    invoke-virtual {v5}, Ljava/nio/channels/SocketChannel;->isConnected()Z

    move-result v5

    if-nez v5, :cond_8

    .line 253
    new-instance v4, Ljava/net/InetSocketAddress;

    invoke-direct {v4, p1, p2}, Ljava/net/InetSocketAddress;-><init>(Ljava/lang/String;I)V

    .line 254
    .local v4, socketAddress:Ljava/net/InetSocketAddress;
    invoke-virtual {v4}, Ljava/net/InetSocketAddress;->isUnresolved()Z

    move-result v5

    if-eqz v5, :cond_2

    .line 255
    new-instance v5, Ljava/io/IOException;

    const-string v6, "Unresolved host address!"

    invoke-direct {v5, v6}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v5

    .line 258
    :cond_2
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    const/4 v6, 0x0

    invoke-virtual {v5, v6}, Ljava/nio/channels/SocketChannel;->configureBlocking(Z)Ljava/nio/channels/SelectableChannel;

    .line 259
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    invoke-virtual {v5, v4}, Ljava/nio/channels/SocketChannel;->connect(Ljava/net/SocketAddress;)Z

    .line 260
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSelector:Ljava/nio/channels/Selector;

    if-eqz v5, :cond_3

    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSelector:Ljava/nio/channels/Selector;

    invoke-virtual {v5}, Ljava/nio/channels/Selector;->isOpen()Z

    move-result v5

    if-nez v5, :cond_4

    .line 261
    :cond_3
    invoke-static {}, Ljava/nio/channels/Selector;->open()Ljava/nio/channels/Selector;

    move-result-object v5

    iput-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSelector:Ljava/nio/channels/Selector;

    .line 264
    :cond_4
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    iget-object v6, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSelector:Ljava/nio/channels/Selector;

    const/16 v7, 0x8

    invoke-virtual {v5, v6, v7}, Ljava/nio/channels/SocketChannel;->register(Ljava/nio/channels/Selector;I)Ljava/nio/channels/SelectionKey;

    .line 266
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSelector:Ljava/nio/channels/Selector;

    const-wide/16 v6, 0x7530

    invoke-virtual {v5, v6, v7}, Ljava/nio/channels/Selector;->select(J)I

    move-result v3

    .line 267
    .local v3, result:I
    const-string v5, "SUPLJ"

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "Result of select(): "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v8, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 269
    if-lez v3, :cond_7

    .line 270
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSelector:Ljava/nio/channels/Selector;

    invoke-virtual {v5}, Ljava/nio/channels/Selector;->selectedKeys()Ljava/util/Set;

    move-result-object v5

    invoke-interface {v5}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .line 271
    .local v0, it:Ljava/util/Iterator;,"Ljava/util/Iterator<Ljava/nio/channels/SelectionKey;>;"
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_8

    .line 272
    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/nio/channels/SelectionKey;

    .line 273
    .local v1, key:Ljava/nio/channels/SelectionKey;
    invoke-virtual {v1}, Ljava/nio/channels/SelectionKey;->readyOps()I

    move-result v5

    and-int/lit8 v5, v5, 0x8

    if-eqz v5, :cond_6

    .line 274
    const-string v5, "SUPLJ"

    const-string v5, "Ready to connect to server."

    invoke-static {v8, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 275
    invoke-virtual {v1}, Ljava/nio/channels/SelectionKey;->channel()Ljava/nio/channels/SelectableChannel;

    move-result-object v2

    check-cast v2, Ljava/nio/channels/SocketChannel;

    .line 276
    .local v2, keyChannel:Ljava/nio/channels/SocketChannel;
    invoke-virtual {v2}, Ljava/nio/channels/SocketChannel;->isConnectionPending()Z

    move-result v5

    if-eqz v5, :cond_6

    .line 277
    :goto_1
    invoke-virtual {v2}, Ljava/nio/channels/SocketChannel;->finishConnect()Z

    move-result v5

    if-nez v5, :cond_5

    .line 279
    const-string v5, "SUPLJ"

    const-string v5, "Waitting for connection to be established..."

    invoke-static {v8, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_1

    .line 281
    :cond_5
    const-string v5, "SUPLJ"

    const-string v5, "Connection established successfully."

    invoke-static {v8, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 282
    invoke-virtual {v1}, Ljava/nio/channels/SelectionKey;->interestOps()I

    move-result v5

    and-int/lit8 v5, v5, -0x9

    invoke-virtual {v1, v5}, Ljava/nio/channels/SelectionKey;->interestOps(I)Ljava/nio/channels/SelectionKey;

    .line 285
    .end local v2           #keyChannel:Ljava/nio/channels/SocketChannel;
    :cond_6
    invoke-interface {v0}, Ljava/util/Iterator;->remove()V

    goto :goto_0

    .line 288
    .end local v0           #it:Ljava/util/Iterator;,"Ljava/util/Iterator<Ljava/nio/channels/SelectionKey;>;"
    .end local v1           #key:Ljava/nio/channels/SelectionKey;
    :cond_7
    const-string v5, "SUPLJ"

    const-string v5, "Timeout"

    invoke-static {v8, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 289
    iget-object v5, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    invoke-virtual {v5}, Ljava/nio/channels/SocketChannel;->close()V

    .line 290
    new-instance v5, Ljava/io/IOException;

    const-string v6, "Connect failed"

    invoke-direct {v5, v6}, Ljava/io/IOException;-><init>(Ljava/lang/String;)V

    throw v5

    .line 293
    .end local v3           #result:I
    .end local v4           #socketAddress:Ljava/net/InetSocketAddress;
    :cond_8
    return-void
.end method

.method private openTlsSession(Ljava/lang/String;ILjava/lang/String;)V
    .locals 2
    .parameter "host"
    .parameter "port"
    .parameter "fqdn"
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/security/GeneralSecurityException;,
            Ljava/io/IOException;
        }
    .end annotation

    .prologue
    .line 364
    invoke-direct {p0}, Lcom/motorola/android/locationproxy/SuplDataService;->initKeyManagers()V

    .line 365
    invoke-direct {p0, p1, p2}, Lcom/motorola/android/locationproxy/SuplDataService;->initSslSocket(Ljava/lang/String;I)V

    .line 366
    iget-object v0, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSslSocket:Ljavax/net/ssl/SSLSocket;

    invoke-virtual {v0}, Ljavax/net/ssl/SSLSocket;->getSession()Ljavax/net/ssl/SSLSession;

    move-result-object v0

    invoke-direct {p0, p3, v0}, Lcom/motorola/android/locationproxy/SuplDataService;->verifyCnSan(Ljava/lang/String;Ljavax/net/ssl/SSLSession;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 367
    const-string v0, "FTOUTPUT"

    const-string v1, "CN or SAN Verification failed."

    invoke-static {v0, v1}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 369
    new-instance v0, Ljava/security/GeneralSecurityException;

    const-string v1, "Common Name or Subject Alternative Name Verification failed."

    invoke-direct {v0, v1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 373
    :cond_0
    return-void
.end method

.method private verifyCnSan(Ljava/lang/String;Ljavax/net/ssl/SSLSession;)Z
    .locals 2
    .parameter "fqdn"
    .parameter "session"

    .prologue
    .line 376
    new-instance v0, Lcom/motorola/android/locationproxy/FqdnVerifier;

    invoke-direct {v0}, Lcom/motorola/android/locationproxy/FqdnVerifier;-><init>()V

    .line 377
    .local v0, v:Ljavax/net/ssl/HostnameVerifier;
    invoke-interface {v0, p1, p2}, Ljavax/net/ssl/HostnameVerifier;->verify(Ljava/lang/String;Ljavax/net/ssl/SSLSession;)Z

    move-result v1

    return v1
.end method


# virtual methods
.method public close()V
    .locals 4

    .prologue
    const-string v3, "SUPLJ"

    .line 468
    const/4 v1, 0x0

    iput-boolean v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mIsTlsMode:Z

    .line 470
    :try_start_0
    iget-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    if-eqz v1, :cond_0

    .line 471
    iget-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    invoke-virtual {v1}, Ljava/lang/Thread;->interrupt()V

    .line 472
    const/4 v1, 0x0

    iput-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    .line 475
    :cond_0
    iget-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSelector:Ljava/nio/channels/Selector;

    if-eqz v1, :cond_1

    .line 476
    iget-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSelector:Ljava/nio/channels/Selector;

    invoke-virtual {v1}, Ljava/nio/channels/Selector;->wakeup()Ljava/nio/channels/Selector;

    .line 477
    iget-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSelector:Ljava/nio/channels/Selector;

    invoke-virtual {v1}, Ljava/nio/channels/Selector;->close()V

    .line 480
    :cond_1
    iget-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSslSocket:Ljavax/net/ssl/SSLSocket;

    if-eqz v1, :cond_2

    .line 481
    iget-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSslSocket:Ljavax/net/ssl/SSLSocket;

    invoke-virtual {v1}, Ljavax/net/ssl/SSLSocket;->close()V

    .line 484
    :cond_2
    iget-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    if-eqz v1, :cond_3

    .line 485
    iget-object v1, p0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    invoke-virtual {v1}, Ljava/nio/channels/SocketChannel;->close()V

    .line 488
    :cond_3
    const-string v1, "SUPLJ"

    const-string v2, "Closing done!"

    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 493
    :goto_0
    return-void

    .line 489
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 490
    .local v0, e:Ljava/io/IOException;
    invoke-virtual {v0}, Ljava/io/IOException;->printStackTrace()V

    .line 491
    const-string v1, "SUPLJ"

    invoke-virtual {v0}, Ljava/io/IOException;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v3, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method

.method public handleMessage(Landroid/os/Message;)V
    .locals 21
    .parameter "msg"

    .prologue
    .line 92
    const-string v17, "SUPLJ"

    new-instance v18, Ljava/lang/StringBuilder;

    invoke-direct/range {v18 .. v18}, Ljava/lang/StringBuilder;-><init>()V

    const-string v19, "Message Received:"

    invoke-virtual/range {v18 .. v19}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v18

    move-object/from16 v0, p1

    iget v0, v0, Landroid/os/Message;->what:I

    move/from16 v19, v0

    invoke-virtual/range {v18 .. v19}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v18

    invoke-virtual/range {v18 .. v18}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v18

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 93
    move-object/from16 v0, p1

    iget v0, v0, Landroid/os/Message;->what:I

    move/from16 v17, v0

    packed-switch v17, :pswitch_data_0

    .line 241
    :pswitch_0
    const-string v17, "SUPLJ"

    const-string v18, "Oops! Shouldn\'t be here."

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 244
    .end local p1
    :goto_0
    return-void

    .line 96
    .restart local p1
    :pswitch_1
    invoke-static/range {p1 .. p1}, Lcom/motorola/android/locationproxy/SuplDataService;->msg2ObjArray(Landroid/os/Message;)[Ljava/lang/Object;

    move-result-object v7

    .line 97
    .local v7, data:[Ljava/lang/Object;
    const/16 v17, 0x0

    aget-object p1, v7, v17

    .end local p1
    check-cast p1, Ljava/lang/Integer;

    invoke-virtual/range {p1 .. p1}, Ljava/lang/Integer;->intValue()I

    move-result v6

    .line 98
    .local v6, cmdId:I
    const/16 v17, 0x1

    aget-object p1, v7, v17

    check-cast p1, Ljava/lang/Integer;

    invoke-virtual/range {p1 .. p1}, Ljava/lang/Integer;->intValue()I

    move-result v14

    .line 99
    .local v14, linkId:I
    const/16 v17, 0x4

    aget-object p1, v7, v17

    check-cast p1, Ljava/lang/Integer;

    invoke-virtual/range {p1 .. p1}, Ljava/lang/Integer;->intValue()I

    move-result v5

    .line 100
    .local v5, addressType:I
    if-nez v5, :cond_2

    const/16 v17, 0x2

    aget-object p1, v7, v17

    check-cast p1, Ljava/lang/Integer;

    invoke-virtual/range {p1 .. p1}, Ljava/lang/Integer;->intValue()I

    move-result v17

    invoke-static/range {v17 .. v17}, Lcom/motorola/android/locationproxy/SuplDataService;->intToIp(I)Ljava/lang/String;

    move-result-object v17

    :goto_1
    move-object/from16 v0, v17

    move-object/from16 v1, p0

    iput-object v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mHost:Ljava/lang/String;

    .line 102
    const/16 v17, 0x3

    aget-object p1, v7, v17

    check-cast p1, Ljava/lang/Short;

    invoke-virtual/range {p1 .. p1}, Ljava/lang/Short;->shortValue()S

    move-result v17

    move/from16 v0, v17

    move-object/from16 v1, p0

    iput-short v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mPort:S

    .line 104
    const-string v17, "SUPLJ"

    new-instance v18, Ljava/lang/StringBuilder;

    invoke-direct/range {v18 .. v18}, Ljava/lang/StringBuilder;-><init>()V

    const-string v19, "CmdId:"

    invoke-virtual/range {v18 .. v19}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v18

    move-object/from16 v0, v18

    move v1, v6

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v18

    const-string v19, " addressType:"

    invoke-virtual/range {v18 .. v19}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v18

    move-object/from16 v0, v18

    move v1, v5

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v18

    const-string v19, " mHost:"

    invoke-virtual/range {v18 .. v19}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v18

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mHost:Ljava/lang/String;

    move-object/from16 v19, v0

    invoke-virtual/range {v18 .. v19}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v18

    const-string v19, " mPort:"

    invoke-virtual/range {v18 .. v19}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v18

    move-object/from16 v0, p0

    iget-short v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mPort:S

    move/from16 v19, v0

    const v20, 0xffff

    and-int v19, v19, v20

    invoke-virtual/range {v18 .. v19}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v18

    invoke-virtual/range {v18 .. v18}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v18

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 108
    :try_start_0
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    move-object/from16 v17, v0

    if-eqz v17, :cond_0

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    move-object/from16 v17, v0

    invoke-virtual/range {v17 .. v17}, Ljava/nio/channels/SocketChannel;->isOpen()Z

    move-result v17

    if-eqz v17, :cond_0

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    move-object/from16 v17, v0

    invoke-virtual/range {v17 .. v17}, Ljava/nio/channels/SocketChannel;->isConnected()Z

    move-result v17

    if-nez v17, :cond_3

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    move-object/from16 v17, v0

    invoke-virtual/range {v17 .. v17}, Ljava/nio/channels/SocketChannel;->isConnectionPending()Z

    move-result v0

    if-eqz v0, :cond_0

    :goto_7
    invoke-virtual/range {v17 .. v17}, Ljava/nio/channels/SocketChannel;->finishConnect()Z

    move-result v0

    if-nez v0, :cond_3

    const-string v0, "SUPLJ"

    const-string v8, "Waitting for connection to be established...(handleMessage)"

    invoke-static {v0, v8}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_7

    .line 113
    :cond_0
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mHost:Ljava/lang/String;

    move-object/from16 v17, v0

    move-object/from16 v0, p0

    iget-short v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mPort:S

    move/from16 v18, v0

    const v19, 0xffff

    and-int v18, v18, v19

    move-object/from16 v0, p0

    move-object/from16 v1, v17

    move/from16 v2, v18

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/SuplDataService;->openPlainTextConnection(Ljava/lang/String;I)V

    .line 118
    :goto_2
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    move-object/from16 v17, v0

    if-nez v17, :cond_1

    .line 119
    new-instance v17, Ljava/lang/Thread;

    new-instance v18, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;

    const/16 v19, 0x0

    move-object/from16 v0, v18

    move-object/from16 v1, p0

    move-object/from16 v2, v19

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;-><init>(Lcom/motorola/android/locationproxy/SuplDataService;Lcom/motorola/android/locationproxy/SuplDataService$1;)V

    invoke-direct/range {v17 .. v18}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    move-object/from16 v0, v17

    move-object/from16 v1, p0

    iput-object v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    .line 122
    :cond_1
    sget-object v17, Lcom/motorola/android/locationproxy/SuplDataService$3;->$SwitchMap$java$lang$Thread$State:[I

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    move-object/from16 v18, v0

    invoke-virtual/range {v18 .. v18}, Ljava/lang/Thread;->getState()Ljava/lang/Thread$State;

    move-result-object v18

    invoke-virtual/range {v18 .. v18}, Ljava/lang/Thread$State;->ordinal()I

    move-result v18

    aget v17, v17, v18

    packed-switch v17, :pswitch_data_1

    .line 130
    :goto_3
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    move-object/from16 v17, v0

    const/16 v18, 0x0

    move-object/from16 v0, v17

    move v1, v6

    move v2, v14

    move/from16 v3, v18

    invoke-interface {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/ISuplCommands;->sendOpenSocketResult(III)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    goto/16 :goto_0

    .line 131
    :catch_0
    move-exception v17

    move-object/from16 v13, v17

    .line 132
    .local v13, ioe:Ljava/io/IOException;
    const-string v17, "SUPLJ"

    const-string v18, "IOException "

    move-object/from16 v0, v17

    move-object/from16 v1, v18

    move-object v2, v13

    invoke-static {v0, v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 133
    invoke-virtual {v13}, Ljava/io/IOException;->printStackTrace()V

    .line 134
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    move-object/from16 v17, v0

    const/16 v18, -0x1

    move-object/from16 v0, v17

    move v1, v6

    move v2, v14

    move/from16 v3, v18

    invoke-interface {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/ISuplCommands;->sendOpenSocketResult(III)V

    goto/16 :goto_0

    .line 100
    .end local v13           #ioe:Ljava/io/IOException;
    :cond_2
    new-instance v17, Ljava/lang/String;

    const/16 v18, 0x5

    aget-object p1, v7, v18

    check-cast p1, [B

    check-cast p1, [B

    move-object/from16 v0, v17

    move-object/from16 v1, p1

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>([B)V

    goto/16 :goto_1

    .line 116
    :cond_3
    :try_start_1
    const-string v17, "SUPLJ"

    const-string v18, "Oops! Already connected."

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto/16 :goto_2

    .line 124
    :pswitch_2
    new-instance v17, Ljava/lang/Thread;

    new-instance v18, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;

    const/16 v19, 0x0

    move-object/from16 v0, v18

    move-object/from16 v1, p0

    move-object/from16 v2, v19

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/SuplDataService$PlainTextWorkerThread;-><init>(Lcom/motorola/android/locationproxy/SuplDataService;Lcom/motorola/android/locationproxy/SuplDataService$1;)V

    invoke-direct/range {v17 .. v18}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    move-object/from16 v0, v17

    move-object/from16 v1, p0

    iput-object v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    .line 127
    :pswitch_3
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    move-object/from16 v17, v0

    invoke-virtual/range {v17 .. v17}, Ljava/lang/Thread;->start()V
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_0

    goto :goto_3

    .line 140
    .end local v5           #addressType:I
    .end local v6           #cmdId:I
    .end local v7           #data:[Ljava/lang/Object;
    .end local v14           #linkId:I
    .restart local p1
    :pswitch_4
    const/4 v10, 0x0

    .line 141
    .local v10, errorCode:B
    invoke-static/range {p1 .. p1}, Lcom/motorola/android/locationproxy/SuplDataService;->msg2ObjArray(Landroid/os/Message;)[Ljava/lang/Object;

    move-result-object v7


    .line 142
    .restart local v7       #data:[Ljava/lang/Object;
    const/16 v17, 0x0

    aget-object p1, v7, v17

    .end local p1
    check-cast p1, Ljava/lang/Integer;

    invoke-virtual/range {p1 .. p1}, Ljava/lang/Integer;->intValue()I

    move-result v6

    .line 143
    .restart local v6       #cmdId:I
    const/16 v17, 0x1

    aget-object p1, v7, v17

    check-cast p1, Ljava/lang/Integer;

    invoke-virtual/range {p1 .. p1}, Ljava/lang/Integer;->intValue()I

    move-result v14

    .line 144
    .restart local v14       #linkId:I
    new-instance v11, Ljava/lang/String;

    const/16 v17, 0x2

    aget-object p1, v7, v17

    check-cast p1, [B

    check-cast p1, [B

    move-object v0, v11

    move-object/from16 v1, p1

    invoke-direct {v0, v1}, Ljava/lang/String;-><init>([B)V

    .line 145
    .local v11, fqdn:Ljava/lang/String;
    const-string v17, "SUPLJ"

    new-instance v18, Ljava/lang/StringBuilder;

    invoke-direct/range {v18 .. v18}, Ljava/lang/StringBuilder;-><init>()V

    const-string v19, "fqdn="

    invoke-virtual/range {v18 .. v19}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v18

    move-object/from16 v0, v18

    move-object v1, v11

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v18

    invoke-virtual/range {v18 .. v18}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v18

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 147
    :try_start_2
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    move-object/from16 v17, v0

    if-eqz v17, :cond_6

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    move-object/from16 v17, v0

    invoke-virtual/range {v17 .. v17}, Ljava/nio/channels/SocketChannel;->isConnected()Z

    move-result v17

    if-eqz v17, :cond_6

    .line 148
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    move-object/from16 v17, v0

    if-eqz v17, :cond_4

    .line 149
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    move-object/from16 v17, v0

    invoke-virtual/range {v17 .. v17}, Ljava/lang/Thread;->interrupt()V

    .line 150
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mSelector:Ljava/nio/channels/Selector;

    move-object/from16 v17, v0

    invoke-virtual/range {v17 .. v17}, Ljava/nio/channels/Selector;->wakeup()Ljava/nio/channels/Selector;

    .line 152
    const/16 v17, 0x0

    move-object/from16 v0, v17

    move-object/from16 v1, p0

    iput-object v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    .line 157
    :cond_4
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mHost:Ljava/lang/String;

    move-object/from16 v17, v0

    move-object/from16 v0, p0

    iget-short v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mPort:S

    move/from16 v18, v0

    const v19, 0xffff

    and-int v18, v18, v19

    move-object/from16 v0, p0

    move-object/from16 v1, v17

    move/from16 v2, v18

    move-object v3, v11

    invoke-direct {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/SuplDataService;->openTlsSession(Ljava/lang/String;ILjava/lang/String;)V

    .line 159
    new-instance v17, Ljava/lang/Thread;

    new-instance v18, Lcom/motorola/android/locationproxy/SuplDataService$SslWorkerThread;

    const/16 v19, 0x0

    move-object/from16 v0, v18

    move-object/from16 v1, p0

    move-object/from16 v2, v19

    invoke-direct {v0, v1, v2}, Lcom/motorola/android/locationproxy/SuplDataService$SslWorkerThread;-><init>(Lcom/motorola/android/locationproxy/SuplDataService;Lcom/motorola/android/locationproxy/SuplDataService$1;)V

    invoke-direct/range {v17 .. v18}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V

    move-object/from16 v0, v17

    move-object/from16 v1, p0

    iput-object v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    .line 160
    const/16 v17, 0x1

    move/from16 v0, v17

    move-object/from16 v1, p0

    iput-boolean v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mIsTlsMode:Z

    .line 161
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    move-object/from16 v17, v0

    invoke-virtual/range {v17 .. v17}, Ljava/lang/Thread;->start()V
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0
    .catch Ljava/security/GeneralSecurityException; {:try_start_2 .. :try_end_2} :catch_1
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_2

    .line 174
    :goto_4
    if-eqz v10, :cond_5

    .line 175
    invoke-virtual/range {p0 .. p0}, Lcom/motorola/android/locationproxy/SuplDataService;->close()V

    .line 176
    const/16 v17, 0x0

    move/from16 v0, v17

    move-object/from16 v1, p0

    iput-boolean v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mIsTlsMode:Z

    .line 178
    :cond_5
    const-string v17, "SUPLJ"

    new-instance v18, Ljava/lang/StringBuilder;

    invoke-direct/range {v18 .. v18}, Ljava/lang/StringBuilder;-><init>()V

    const-string v19, "errorCode = "

    invoke-virtual/range {v18 .. v19}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v18

    move-object/from16 v0, v18

    move v1, v10

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v18

    invoke-virtual/range {v18 .. v18}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v18

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 179
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    move-object/from16 v17, v0

    :goto_5
    move-object/from16 v0, v17

    move v1, v6

    move v2, v14

    move v3, v10

    invoke-interface {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/ISuplCommands;->sendTlsResult(IIB)V

    goto/16 :goto_0

    .line 163
    :cond_6
    :try_start_3
    const-string v17, "SUPLJ"

    const-string v18, "What?! Shouldn\'t be here."

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0
    .catch Ljava/security/GeneralSecurityException; {:try_start_3 .. :try_end_3} :catch_1
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_3} :catch_2

    .line 164
    const/4 v10, 0x1

    goto :goto_4

    .line 166
    :catch_1
    move-exception v17

    move-object/from16 v12, v17

    .line 167
    .local v12, gse:Ljava/security/GeneralSecurityException;
    :try_start_4
    const-string v17, "FTOUTPUT"

    invoke-static {v12}, Landroid/util/Log;->getStackTraceString(Ljava/lang/Throwable;)Ljava/lang/String;

    move-result-object v18

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_0

    .line 168
    const/4 v10, 0x2

    .line 174
    if-eqz v10, :cond_7

    .line 175
    invoke-virtual/range {p0 .. p0}, Lcom/motorola/android/locationproxy/SuplDataService;->close()V

    .line 176
    const/16 v17, 0x0

    move/from16 v0, v17

    move-object/from16 v1, p0

    iput-boolean v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mIsTlsMode:Z

    .line 178
    :cond_7
    const-string v17, "SUPLJ"

    new-instance v18, Ljava/lang/StringBuilder;

    invoke-direct/range {v18 .. v18}, Ljava/lang/StringBuilder;-><init>()V

    const-string v19, "errorCode = "

    invoke-virtual/range {v18 .. v19}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v18

    move-object/from16 v0, v18

    move v1, v10

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v18

    invoke-virtual/range {v18 .. v18}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v18

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 179
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    move-object/from16 v17, v0

    goto :goto_5

    .line 169
    .end local v12           #gse:Ljava/security/GeneralSecurityException;
    :catch_2
    move-exception v17

    move-object/from16 v13, v17

    .line 170
    .restart local v13       #ioe:Ljava/io/IOException;
    :try_start_5
    const-string v17, "FTOUTPUT"

    invoke-static {v13}, Landroid/util/Log;->getStackTraceString(Ljava/lang/Throwable;)Ljava/lang/String;

    move-result-object v18

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 171
    invoke-virtual {v13}, Ljava/io/IOException;->printStackTrace()V
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_0

    .line 172
    const/4 v10, 0x1

    .line 174
    if-eqz v10, :cond_8

    .line 175
    invoke-virtual/range {p0 .. p0}, Lcom/motorola/android/locationproxy/SuplDataService;->close()V

    .line 176
    const/16 v17, 0x0

    move/from16 v0, v17

    move-object/from16 v1, p0

    iput-boolean v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mIsTlsMode:Z

    .line 178
    :cond_8
    const-string v17, "SUPLJ"

    new-instance v18, Ljava/lang/StringBuilder;

    invoke-direct/range {v18 .. v18}, Ljava/lang/StringBuilder;-><init>()V

    const-string v19, "errorCode = "

    invoke-virtual/range {v18 .. v19}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v18

    move-object/from16 v0, v18

    move v1, v10

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v18

    invoke-virtual/range {v18 .. v18}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v18

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 179
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    move-object/from16 v17, v0

    goto/16 :goto_5

    .line 174
    .end local v13           #ioe:Ljava/io/IOException;
    :catchall_0
    move-exception v17

    if-eqz v10, :cond_9

    .line 175
    invoke-virtual/range {p0 .. p0}, Lcom/motorola/android/locationproxy/SuplDataService;->close()V

    .line 176
    const/16 v18, 0x0

    move/from16 v0, v18

    move-object/from16 v1, p0

    iput-boolean v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mIsTlsMode:Z

    .line 178
    :cond_9
    const-string v18, "SUPLJ"

    new-instance v19, Ljava/lang/StringBuilder;

    invoke-direct/range {v19 .. v19}, Ljava/lang/StringBuilder;-><init>()V

    const-string v20, "errorCode = "

    invoke-virtual/range {v19 .. v20}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v19

    move-object/from16 v0, v19

    move v1, v10

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v19

    invoke-virtual/range {v19 .. v19}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v19

    invoke-static/range {v18 .. v19}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 179
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    move-object/from16 v18, v0

    move-object/from16 v0, v18

    move v1, v6

    move v2, v14

    move v3, v10

    invoke-interface {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/ISuplCommands;->sendTlsResult(IIB)V

    .line 174
    throw v17

    .line 185
    .end local v6           #cmdId:I
    .end local v7           #data:[Ljava/lang/Object;
    .end local v10           #errorCode:B
    .end local v11           #fqdn:Ljava/lang/String;
    .end local v14           #linkId:I
    .restart local p1
    :pswitch_5
    invoke-static/range {p1 .. p1}, Lcom/motorola/android/locationproxy/SuplDataService;->msg2ObjArray(Landroid/os/Message;)[Ljava/lang/Object;

    move-result-object v7

    .line 186
    .restart local v7       #data:[Ljava/lang/Object;
    const/16 v17, 0x0

    aget-object p1, v7, v17

    .end local p1
    check-cast p1, Ljava/lang/Integer;

    invoke-virtual/range {p1 .. p1}, Ljava/lang/Integer;->intValue()I

    move-result v6

    .line 187
    .restart local v6       #cmdId:I
    const/16 v17, 0x1

    aget-object p1, v7, v17

    check-cast p1, Ljava/lang/Integer;

    invoke-virtual/range {p1 .. p1}, Ljava/lang/Integer;->intValue()I

    move-result v14

    .line 188
    .restart local v14       #linkId:I
    const/16 v17, 0x2

    aget-object p1, v7, v17

    check-cast p1, [B

    move-object/from16 v0, p1

    check-cast v0, [B

    move-object v8, v0

    .line 190
    .local v8, dataToServer:[B
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    move-object/from16 v17, v0

    if-eqz v17, :cond_b

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mSocketChannel:Ljava/nio/channels/SocketChannel;

    move-object/from16 v17, v0

    invoke-virtual/range {v17 .. v17}, Ljava/nio/channels/SocketChannel;->isConnected()Z

    move-result v17

    if-eqz v17, :cond_b

    .line 192
    const/16 v17, 0x1d

    :try_start_6
    move/from16 v0, v17

    new-array v0, v0, [B

    move-object v4, v0

    fill-array-data v4, :array_0

    .line 197
    .local v4, _data:[B
    move-object/from16 v0, p0

    iget-boolean v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mIsTlsMode:Z

    move/from16 v17, v0

    if-eqz v17, :cond_a

    .line 198
    const-string v17, "SUPLJ"

    const-string v18, "Sending encrypted data to server..."

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 199
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mSslSocket:Ljavax/net/ssl/SSLSocket;

    move-object/from16 v17, v0

    invoke-virtual/range {v17 .. v17}, Ljavax/net/ssl/SSLSocket;->getOutputStream()Ljava/io/OutputStream;

    move-result-object v15

    .line 200
    .local v15, oStream:Ljava/io/OutputStream;
    check-cast v8, [B

    .end local v8           #dataToServer:[B
    invoke-virtual {v15, v8}, Ljava/io/OutputStream;->write([B)V

    .line 201
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    move-object/from16 v17, v0

    const/16 v18, 0x0

    move-object/from16 v0, v17

    move v1, v6

    move v2, v14

    move/from16 v3, v18

    invoke-interface {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/ISuplCommands;->sendSocketDataResult(III)V
    :try_end_6
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_6} :catch_3

    goto/16 :goto_0

    .line 207
    .end local v4           #_data:[B
    .end local v15           #oStream:Ljava/io/OutputStream;
    :catch_3
    move-exception v17

    move-object/from16 v9, v17

    .line 208
    .local v9, e:Ljava/lang/Exception;
    const-string v17, "SUPLJ"

    const-string v18, "Error sending data to server."

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 209
    invoke-virtual {v9}, Ljava/lang/Exception;->printStackTrace()V

    .line 210
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    move-object/from16 v17, v0

    const/16 v18, -0x1

    move-object/from16 v0, v17

    move v1, v6

    move v2, v14

    move/from16 v3, v18

    invoke-interface {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/ISuplCommands;->sendSocketDataResult(III)V

    goto/16 :goto_0

    .line 203
    .end local v9           #e:Ljava/lang/Exception;
    .restart local v4       #_data:[B
    .restart local v8       #dataToServer:[B
    :cond_a
    :try_start_7
    const-string v17, "SUPLJ"

    const-string v18, "Sending plain text to server..."

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 204
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mDataHandler:Lcom/motorola/android/locationproxy/SuplDataService$DataHandler;

    move-object/from16 v17, v0

    check-cast v8, [B

    .end local v8           #dataToServer:[B
    move-object/from16 v0, v17

    move-object v1, v8

    invoke-virtual {v0, v1}, Lcom/motorola/android/locationproxy/SuplDataService$DataHandler;->sendData([B)V

    .line 205
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    move-object/from16 v17, v0

    const/16 v18, 0x0

    move-object/from16 v0, v17

    move v1, v6

    move v2, v14

    move/from16 v3, v18

    invoke-interface {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/ISuplCommands;->sendSocketDataResult(III)V
    :try_end_7
    .catch Ljava/lang/Exception; {:try_start_7 .. :try_end_7} :catch_3

    goto/16 :goto_0

    .line 213
    .end local v4           #_data:[B
    .restart local v8       #dataToServer:[B
    :cond_b
    const-string v17, "SUPLJ"

    const-string v18, "Connection not established!"

    invoke-static/range {v17 .. v18}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 214
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    move-object/from16 v17, v0

    const/16 v18, -0x1

    move-object/from16 v0, v17

    move v1, v6

    move v2, v14

    move/from16 v3, v18

    invoke-interface {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/ISuplCommands;->sendSocketDataResult(III)V

    goto/16 :goto_0

    .line 219
    .end local v6           #cmdId:I
    .end local v7           #data:[Ljava/lang/Object;
    .end local v8           #dataToServer:[B
    .end local v14           #linkId:I
    .restart local p1
    :pswitch_6
    invoke-static/range {p1 .. p1}, Lcom/motorola/android/locationproxy/SuplDataService;->msg2ObjArray(Landroid/os/Message;)[Ljava/lang/Object;

    move-result-object v7

    .line 220
    .restart local v7       #data:[Ljava/lang/Object;
    const/16 v17, 0x0

    aget-object p1, v7, v17

    .end local p1
    check-cast p1, Ljava/lang/Integer;

    invoke-virtual/range {p1 .. p1}, Ljava/lang/Integer;->intValue()I

    move-result v6

    .line 221
    .restart local v6       #cmdId:I
    const/16 v17, 0x1

    aget-object p1, v7, v17

    check-cast p1, Ljava/lang/Integer;

    invoke-virtual/range {p1 .. p1}, Ljava/lang/Integer;->intValue()I

    move-result v14

    .line 222
    .restart local v14       #linkId:I
    const/16 v17, 0x1

    move/from16 v0, v17

    move-object/from16 v1, p0

    iput-boolean v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mIsClosing:Z

    .line 223
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mWorkerThread:Ljava/lang/Thread;

    move-object/from16 v16, v0

    .line 224
    .local v16, tmpThread:Ljava/lang/Thread;
    invoke-virtual/range {p0 .. p0}, Lcom/motorola/android/locationproxy/SuplDataService;->close()V

    .line 225
    if-eqz v16, :cond_c

    .line 229
    :try_start_8
    invoke-virtual/range {v16 .. v16}, Ljava/lang/Thread;->join()V
    :try_end_8
    .catch Ljava/lang/InterruptedException; {:try_start_8 .. :try_end_8} :catch_4

    .line 235
    :cond_c
    :goto_6
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/motorola/android/locationproxy/SuplDataService;->mShimProxy:Lcom/motorola/android/locationproxy/ISuplCommands;

    move-object/from16 v17, v0

    const/16 v18, 0x0

    move-object/from16 v0, v17

    move v1, v6

    move v2, v14

    move/from16 v3, v18

    invoke-interface {v0, v1, v2, v3}, Lcom/motorola/android/locationproxy/ISuplCommands;->sendCloseSocketResult(III)V

    .line 236
    const/16 v17, 0x0

    move/from16 v0, v17

    move-object/from16 v1, p0

    iput-boolean v0, v1, Lcom/motorola/android/locationproxy/SuplDataService;->mIsClosing:Z

    goto/16 :goto_0

    .line 230
    :catch_4
    move-exception v9

    .line 232
    .local v9, e:Ljava/lang/InterruptedException;
    invoke-virtual {v9}, Ljava/lang/InterruptedException;->printStackTrace()V

    goto :goto_6

    .line 93
    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_1
        :pswitch_5
        :pswitch_0
        :pswitch_6
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_4
    .end packed-switch

    .line 122
    :pswitch_data_1
    .packed-switch 0x1
        :pswitch_2
        :pswitch_3
    .end packed-switch

    .line 192
    :array_0
    .array-data 0x1
        0x0t
        0x1dt
        0x1t
        0x0t
        0x0t
        0x80t
        0x0t
        0x4ct
        0x4ct
        0x80t
        0x18t
        0x18t
        0xc8t
        0xct
        0x9bt
        0xe0t
        0x50t
        0x4t
        0x40t
        0x0t
        0x0t
        0x0t
        0x0t
        0x0t
        0x0t
        0x0t
        0x29t
        0x95t
        0xf4t
    .end array-data
.end method
