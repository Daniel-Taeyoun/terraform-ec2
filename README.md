# Terraform Network + EC2 생성
terraform workspace는 "develop"으로 지정했으며, 각 리소스별(Network, EC2, ELB)로 디렉토리를 나눠 작업했습니다.  
생성된 Infra 구조는 아래와 같으며, EC2에 Docker nginx를 띄워서 실행한 결과입니다.

### Code Structure
- terraform.tfvars
  - terraform.tfvars를 활용해 전역변수를 지정한다.(ex. tfvars_aws_region, tfvars_service_name ...)
  - 지정한 전역변수를 활용해 각 디렉토리별로 symbolic link를 생성해 의존성을 만들었다.
    - why??? Infra 생성 시 공통적으로 들어가는 용어 및 설정은 하나에 응집함으로써 코드 생산성을 높이고자 함이다. 
    - But, 의존도가 너무 높다?라는 단점도 발생한다.
  - 구조는 각 디렉토리별(0-Global, 1-Network ...)로 terraform.tfvars symbolic link를 생성했다.
  - terraform plan & terraform apply 시 terraform.tfvars를 기본적으로 참조하게 되어 있다. 


### Infra 구조
![EC2생성](https://user-images.githubusercontent.com/30804139/224723605-aa432ada-ad7f-4b13-9f6f-814ab21b1a10.jpg)  


### 실행결과
<img width="614" alt="스크린샷 2023-03-13 오후 8 38 16" src="https://user-images.githubusercontent.com/30804139/224733486-71ee5324-b9a7-4bff-934b-4d86d0fde431.png">
