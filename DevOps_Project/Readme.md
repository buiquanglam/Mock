![dev](https://user-images.githubusercontent.com/61420358/227755394-f22e0f5e-dafd-454e-b387-b0fe5053e7e8.png)
- Dùng công cụ SCM ( GitHub ) --> Tạo EC2 cài đặt jenkins server , terraform , helm    -->  Dùng Jenkins Script ( file jenkins_scipt.sh) tạo EKS cluster từ file terraform và helm cài đặt ứng dụng ( bitnami, helm chart , nginx , load balancer) - Sử dụng S3 để lưu file tf.state ( file backend.tf)
- Dùng Jenkins tạo 1 CI/CD pipeline để tạo EKS cluster trên aws sử dụng  terraform , sau khi tạo EKS thì sử dụng helm để cài 1 số packet 
