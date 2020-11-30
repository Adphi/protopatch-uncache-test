# cache / no-cache protoc-gen-go-patch examples

### Example protobuf definition:
```protobuf
syntax = "proto3";

package interfaces;

option go_package = "pb;interfaces";

import "patch/go.proto";
import "protoc-gen-validate/validate/validate.proto";

message Interface {
  string name = 1;
  enum Status {
    UNKNOWN = 0 [(go.value).name = "StatusUnknown"];
    UP = 1 [(go.value).name = "StatusUP"];
    DOWN = 2 [(go.value).name = "StatusDown"];
  }
  Status status = 2 [(validate.rules).enum = {defined_only: true, not_in: [0]}];
  repeated IpAddress addresses = 3;
}

message IpAddress {
  option (go.message).name = "IPAddress";
  oneof Address {
    string ipv4 = 3 [(go.field).name = "IPV4", (validate.rules).string.ipv4 = true];
    string ipv6 = 4 [(go.field).name = "IPV6", (validate.rules).string.ipv6 = true];
  }
}

```

### Basic compilation go test

```golang
package main

import (
	"testing"

	interfaces "github.com/adphi/protopatch-uncache-test/pb"
)

func Test(t *testing.T) {
	_ = &interfaces.Interface{}
}

```

### Generate proto with non-cache version of protoc-gen-go-patch:

```bash
$ make test-no-cache
```
 output:
```
Cleaning proto generated files
Cleaning tools
Installing not cached version
Generating proto
protoc -I. -Ithird_party --go-patch_out=plugin=go,paths=source_relative:. \
                --go-patch_out=plugin=validate,paths=source_relative,lang=go:. \
                pb/interfaces.proto
Testing compilation
# github.com/adphi/protopatch-uncache-test/pb
pb/interfaces.pb.validate.go:144:8: undefined: IpAddress_Ipv4
pb/interfaces.pb.validate.go:146:25: m.GetIpv4 undefined (type *IPAddress has no field or method GetIpv4, but does have GetIPV4)
pb/interfaces.pb.validate.go:153:8: undefined: IpAddress_Ipv6
pb/interfaces.pb.validate.go:155:25: m.GetIpv6 undefined (type *IPAddress has no field or method GetIpv6, but does have GetIPV6)
FAIL    github.com/adphi/protopatch-uncache-test [build failed]
make[1]: [go-test] Error 2 (ignored)

```

### Generate proto with cache version of protoc-gen-go-patch:

```bash
$ make test-cached 
```

output:

```
Cleaning proto generated files
Cleaning tools
Installing cache version
Branch 'cache' set up to track remote branch 'cache' from 'origin'.
Switched to a new branch 'cache'
go install ./cmd/protoc-gen-go-patch
Generating proto
protoc -I. -Ithird_party --go-patch_out=plugin=go,paths=source_relative:. \
                --go-patch_out=plugin=validate,paths=source_relative,lang=go:. \
                pb/interfaces.proto
Testing compilation
=== RUN   Test
--- PASS: Test (0.00s)
PASS
ok      github.com/adphi/protopatch-uncache-test        (cached)
?       github.com/adphi/protopatch-uncache-test/pb     [no test files]

```
