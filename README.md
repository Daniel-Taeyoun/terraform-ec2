# Terraform Network + EC2 생성
terraform workspace는 "develop"으로 지정했으며, 각 리소스별(Network, EC2, ELB)로 디렉토리를 나눠 작업했습니다.  
생성된 Infra 구조는 아래와 같으며, EC2에 Docker nginx를 띄워서 실행한 결과입니다.

### Infra 구조
![EC2생성](https://user-images.githubusercontent.com/30804139/224723605-aa432ada-ad7f-4b13-9f6f-814ab21b1a10.jpg)  


### 실행결과
<img width="614" alt="스크린샷 2023-03-13 오후 8 38 16" src="https://user-images.githubusercontent.com/30804139/224733486-71ee5324-b9a7-4bff-934b-4d86d0fde431.png">
