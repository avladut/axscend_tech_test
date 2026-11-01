/// Which album: its owner and its id, as in `/users/1/albums/2`.
typedef AlbumAddress = ({int userId, int albumId});

/// Which photo: its owner, album and id, as in
/// `/users/1/albums/2/photos/3`.
typedef PhotoAddress = ({int userId, int albumId, int photoId});
