      MODULE Global
      IMPLICIT NONE

C     Program Units adopt CGS [ Centimeter-Gram-Second ] :
C                                                             Length          = [ cm ]
C                                                             Time            = [ Second ]/s
C                                                             Mass            = [ Gram ]/g
C                                                             Temperature     = [ Kelvin ]/K
C                                                          =>
C                                                             Force  = [ g*cm/s^2] = [ dynes ]
C                                                             Energy = [ g*cm*/s^2*cm ] = [ g*cm^2/s^2 ] = [ ergs ]
C                                                             Specific Heat = [ ergs/(mol*K) ]
C                                                             Specific Enthalpy = [ ergs/g ] = [ cm^2/s^2 ]
C                                                             Molecular Weight = [ g/mol ]
C                                                             Mole Production Rate = [ mol/(cm^3*s) ]
C                                                             Diffusion Coef. = [ cm^2/s ]
C                                                             Dynamic Viscousity = [ g/(cm*s) ]
C                                                             Thermal Conductivity = [ ergs/(cm*K*s) ]
C                                                             
C                     
      
      INTEGER :: Iter
      INTEGER :: N                            ! Mesh Nodes
      INTEGER :: N1p,N2p,N3p,N1m,N2m,N3m      ! N1p=N+1,N1m=N-1  
      INTEGER :: ReConstruct_TYPE             ! Type of Re-Consturction  
      INTEGER :: ReConstruct_PC               ! Re-Constructed Variables [ Primitive / Conserved ]
            
      REAL*8,ALLOCATABLE :: Q1(:,:)                           ! ԭʼ���� [ (rho,u,p,Y1...); I ]
      REAL*8,ALLOCATABLE :: Tpt(:)                            ! ԭʼ���� => Temperature
      REAL*8,ALLOCATABLE :: F(:,:),F0(:,:),F1(:,:)            ! �غ���� [ (rho,rho*u,rho*et,rho*Y1...); I ]�� F Ϊ�м�ʱ��, F0 Ϊ N-1ʱ��, F1 Ϊ N ʱ��
      REAL*8,ALLOCATABLE :: F2(:,:)                           ! �غ����                                    �� 3rd-Explicit_TVD_Runge-Kutta ʱ���ƽ��м����
      REAL*8,ALLOCATABLE :: Gc(:,:)                           ! Convective Flux [ Structure = Q1/F ]
      REAL*8,ALLOCATABLE :: Gv(:,:)                           ! Viscous    Flux
      REAL*8,ALLOCATABLE :: Gs(:,:)                           ! Source     Term
      REAL*8,ALLOCATABLE :: X(:)                              ! Mesh Coordinates
      REAL*8,ALLOCATABLE :: Rho(:,:),U(:,:),P(:,:),Msf(:,:,:) ! �ع�������״̬�� �ܶ�, �ٶ�, ѹ��, �����������( Mass Fraction )
      REAL*8,ALLOCATABLE :: Mlw(:)                            ! Molecular Weight of Each Species [ g/mol ]
      REAL*8,ALLOCATABLE :: H(:,:)                            ! Enthalpy of Each Species [ (Ns,I) ]
      REAL*8,ALLOCATABLE :: Dfc(:,:)                          ! Diffusion Coefficient    [ ( Ns, I ) ]
      REAL*8,ALLOCATABLE :: Mu(:)                             ! Viscosity of Mixture [ ( I ) ]
      REAL*8,ALLOCATABLE :: Cc(:)                             ! Conductivity Coefficient of Mixture [ ( I ) ]
      CHARACTER*16,ALLOCATABLE :: SPNAME(:)                   ! Names of Species

C     Other Necessary Variables ?... Remain to be added..
C     ...
      INTEGER :: Ns,Ns1                       ! Number of Species, Ns1=Ns-1
      INTEGER :: NT,NT1                       ! Number of total conserved variables ! NT = Ns + 3 , NT1=NT-1



      REAL*8 :: dt                                           ! ͳһʱ�䲽��
      REAL*8 :: dh                                           ! ��������ߴ�
      REAL*8 :: Length                                       ! �������ܳ���
      REAL*8 :: Time                                         ! ��ǰ����ʱ��
      REAL*8 :: ETime                                        ! ������ֹʱ��
      CHARACTER(8) :: NN                                     ! ��������
      
      REAL*8,PARAMETER :: Pi=3.1415926535898_8               ! Pi
      REAL*8,PARAMETER :: Tiny=1.0E-20_8                     ! �����ĸΪ��
      REAL*8,DIMENSION(2),PARAMETER :: X0=( /400_8,800_8/ )               ! Initial Temperature for Secant Method

      REAL*8 :: R0                    ! Universal Gas Constant [ ergs/(mol*K) ]

           
      
      END MODULE Global


