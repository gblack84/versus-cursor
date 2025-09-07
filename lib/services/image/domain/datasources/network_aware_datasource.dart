abstract class INetworkAwareDataSource {
  bool get isConnected;
}

abstract class IRemoteImageDataSource {
  // TODO: Implement remote image datasource methods
}

abstract class IImageOptimizerDataSource {
  // TODO: Implement image optimizer datasource methods
}

class NetworkAwareDataSource implements INetworkAwareDataSource {
  @override
  bool get isConnected => true; // TODO: Implement actual network check
}

class RemoteImageDataSource implements IRemoteImageDataSource {
  // TODO: Implement methods
}

class ImageOptimizerDataSource implements IImageOptimizerDataSource {
  // TODO: Implement methods
}
