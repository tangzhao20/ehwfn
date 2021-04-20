module nrtype
!
! follow the convention of Numerical Recipes
  INTEGER, PARAMETER :: SP = KIND(1.0)
  INTEGER, PARAMETER :: DP = KIND(1.0D0)
  INTEGER, PARAMETER :: SPC = KIND((1.0,1.0))
  INTEGER, PARAMETER :: DPC = KIND((1.0D0,1.0D0))
! mathematical constants
! REAL(SP), PARAMETER :: PI=3.1415926535897932384626433832795_sp
  REAL(DP), PARAMETER :: PI_D=3.14159265358979323846264338327_dp
  REAL(DP), PARAMETER :: RYD=13.605826_dp
  REAL(DP), PARAMETER :: TOL_Small=1.0D-6
  REAL(DP), PARAMETER :: TOL_Zero=1.0D-12
  REAL(DP), parameter, public :: bohr = 0.52917720859
  REAL(DP), parameter, public :: done = 1.0_dp
  REAL(DP), parameter, public    :: twopi = 2*PI_D
  COMPLEX(DP), parameter, public :: cmplx_i = (0.0_dp,1.0_dp)
  COMPLEX(DP), parameter, public :: cmplx_1 = (1.0_dp,0.0_dp)
  REAL(DP), PARAMETER :: MByte=1048576.d0
END MODULE nrtype


