# hive:file-registry
Package implementing common file actions for HIVE applications. An example (with settings) is in the example directory.

---

## API

#### FileRegistry.findOne() - _anywhere_
returns an object with keys:
  * `filename` - name of file originally uploaded
  * `filenameOnDisk` - unique name within FileRegistry.getFileRoot()
  * `uploaded` - number of bytes transmitted to server
  * `size` - number of bytes of the file
  * `timestamp` - when the file was uploaded
  * `userId` - user id of uploader
  * `md5` - checksum
  * `thumbnail` - name of file on disk of a thumbnail generated for the file

#### FileRegistry.upload(file, cb) - _client_
Uploads a File or Blob to the server, and invokes cb when done uploading.  The function cb will be passed a single parameter:
  * `fileId` - id representing the uploaded file in FileRegistry

#### FileRegistry.getFileRoot() - _server_
returns local filesystem path used to store uploads and registered files, e.g., /home/user/app/.meteor/files


#### FileRegistry.serveFile - _server_
plug into iron:router to create a server-side route for serving uploads

FileRegistry.serveFile optionally accepts a single argument of an object with any of the following keys:

  * `disposition` - defaults to `inline`, but specify `attachment` to force a
    download dialog on the client's browser
  * `allowAccess` - function to verify that the requester has permissions to
    download the file.  `this` inside the function will be the Express context
    passed into the server-side route handler.  function should return `true` to
    grant access and continue serving the file, or `false` to generate a 403 error.
    If unspecified, access will be granted to any requester.

_Example:_

    Router.route 'serveFile',
      path: '/file/:filename'
      where: 'server'
      action: FileRegistry.serveFile

#### FileRegistry.onUploaded(cb) - _server_
register a callback function to execute after an file finishes uploading.  The function will be passed a single parameter:
  * `fileDoc` - metadata about the file, from the FileRegistry collection

---

#### Media.pickLocalFile([options,] cb) - _client_
opens a file selector on the client, and uploads selected files to the
FileRegistry.  Accepts an options object that contains any valid input tag
attributes. After each file in the upload completes, the passed callback
function will be called with a single parameter:
  * `fileId` - `_id` of uploaded document in FileRegistry collection

_Example:_

    Media.pickLocalFile {multiple: true, accept '*.jpg'}, (fileId) ->
      console.log "Completed upload of new file, ", fileId

#### Media.capturePhoto(cb) - _client_
take a photo using the default photo app or a webcam in browser, and send it to the server. After the upload completes, the passed callback function will be called with a single parameter:
 * `fileId` - _id of uploaded document in FileRegistry collection

#### Media.captureAudio() - _client_
capture an audio clip using the default recording app or in browser, and send it to the server

#### Media.captureVideo() - _client_
capture a video clip using the default video recording app, and send it to the server

