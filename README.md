hive:file-registry
====================

Package implementing common file actions for HIVE applications. An example (with settings) is in the example directory.

API
---

FileRegistry.findOne() - anywhere - returns an object with keys:
  filename - name of file originally uploaded
  filenameOnDisk - unique name within FileRegistry.getFileRoot()
  uploaded - number of bytes transmitted to server
  size - number of bytes of the file
  timestamp - when the file was uploaded
  userId - user id of uploader
  md5 - checksum
  thumbnail - name of file on disk of a thumbnail generated for the file


FileRegistry.getFileRoot() - server - returns local filesystem path used to store uploads and registered files, e.g., /home/user/app/.meteor/files


FileRegistry.serveFile - server - plug into iron:router to create a server-side route for serving uploads

Example:

    #TODO


sendFile(file, cb) - client - upload a File using DDP

FileRegistry.onUploaded(cb) - server - execute cb, a function with params (fileDoc)

Media.capturePhoto() - client - take a photo using the default photo app or a webcam in browser, and send it to the server

Media.captureAudio() - client - capture an audio clip using the default recording app or in browser, and send it to the server

Media.captureVideo() - client - capture a video clip using the default video recording app, and send it to the server

