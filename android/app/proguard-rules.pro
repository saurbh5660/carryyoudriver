# Apache Tika references Java XML streaming classes that are not available on
# Android. The referenced code path is not used by this app, but R8 needs the
# warning suppressed for release minification to complete.
-dontwarn javax.xml.stream.XMLStreamException
