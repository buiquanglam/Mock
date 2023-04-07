Infrastructure Layer
Dựa trên nền Kubernetes được quản lý bởi AWS (EKS), các dịch vụ được sử dụng bao gồm:

VCS: hệ thống quản lý mã nguồn
AWS IAM: quản lý access vào resources trên AWS, tích hợp với IRSA của AWS để tự động cấp quyền cho các micro-services chạy trong Kubernetes
AWS ACM: quản lý certifcate cho TLS (HTTPS)
AWS Route53: quản lý DNS và routing
AWS CloudFront: dịch vụ CDN nhằm tăng tốc tải trang cho Customer Portal
AWS S3: lưu trữ file tĩnh, truy cập vào S3 sẽ bắt buộc thông qua pre-signed URL
AWS ECR: dịch vụ lưu trữ Docker Images
AWS EKS: Kubernetes trên AWS
Các Kubernetes Worker sẽ được tự động sinh ra và quản lý, scale tùy dựa vào Metrics Server, HPA và Cluster Autoscaler trên Kubernetes
Các Worker dạng EC2 sẽ được chạy trong private subnet, tăng mức độ an ninh cho hệ thống
VPC NAT Gateway: do các worker nằm trong private subnet, các worker này chỉ có thể truy cập Internet thông qua NAT Gateway nằm tại public subnet trên AWS
AWS ELB: Load Balancer trên AWS, ELB sẽ được sinh ra và quản lý tự động bởi Ingress Controller cài đặt trên Kubernetes
AWS RDS: các database của hệ thống sẽ được đặt trong private subnet và chỉ được truy cập từ worker/service trên Kubernetes
VPC Endpoints: tạo private network cho các micro-services truy cập tới AWS S3 và AWS ECR