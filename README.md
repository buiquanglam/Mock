# Mock
Tổng quan pipeline có các stage sau:
- Pull repo từ GitHub về Jenkins Server.
- Cài Maven và build artifact từ Java source code trên Jenkins Server.
- Publish artifact vừa build lên Nexus repo.
- Dùng Ansible tải artifact từ Nexus về Docker host rồi tạo Dockerfile, build image base Tomcat và chạy container deploy Java web app.
