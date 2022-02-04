// Copyright The swift-url Contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import WebURL
import WebURLFoundationExtras

@_cdecl("LLVMFuzzerTestOneInput")
public func web_foundation_roundtrip(_ start: UnsafePointer<UInt8>, _ count: Int) -> CInt {

  let bytes = UnsafeBufferPointer(start: start, count: count)

  // 1. Parse the bytes generated by the fuzzer, and encode the URL for Foundation conversion.

  guard let webURL = WebURL(utf8: bytes)?.encodedForFoundation else {
    return 0  // Fuzzer did not produce a URL. Try again.
  }

  // 2. Convert the encoded WebURL to a Foundation URL.

  guard let foundationURL = URL(webURL, addPercentEncoding: true) else {
    return 0  // Couldn't convert the URL. That's fine.
  }

  // 3. Check that the Foundation URL can be converted back to a WebURL.

  guard let roundtripURL = WebURL(foundationURL) else {
    fatalError(
      """
      URL failed to round-trip:
      - WebURL: \(webURL)
      - Foundation.URL: \(foundationURL)
      """
    )
  }

  // 4. Check that the round-tripped WebURL is exactly the same as the original encoded WebURL.

  guard roundtripURL == webURL, roundtripURL._spis._describesSameStructure(as: webURL) else {
    fatalError(
      """
      Round-tripped URL is not the same as the original:
      - WebURL: \(webURL)
      - Foundation.URL: \(foundationURL)
      - WebURL (2): \(roundtripURL)
      """
    )
  }

  // All checks passed.
  return 0
}
