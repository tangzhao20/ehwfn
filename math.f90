module mat
  use nrtype
contains
  
  function norm(a)
    real(dp) :: norm
    real(dp), intent(in) :: a(3)
    norm = (a(1)**2+a(2)**2+a(3)**2)**0.5
  endfunction norm

  function dot(a, b)
    real(dp) :: dot
    real(dp), intent(in) :: a(3), b(3)
    dot = a(1)*b(1)+a(2)*b(2)+a(3)*b(3)
  endfunction dot

  function cross(a, b)
    real(dp) :: cross(3)
    real(dp), intent(in) :: a(3), b(3)
    cross(1) = a(2) * b(3) - a(3) * b(2)
    cross(2) = a(3) * b(1) - a(1) * b(3)
    cross(3) = a(1) * b(2) - a(2) * b(1)
  endfunction cross

  function dpp(a, b)
  ! distance from point a to point b
    real(dp) :: dpp
    real(dp), intent(in) :: a(3), b(3)
    dpp=norm(a-b)
  endfunction dpp
  
  function dpl(c, a, b)
  ! distance from point c to line a-b
    real(dp) :: dpl
    real(dp), intent(in) :: c(3), a(3), b(3)
    dpl=norm(cross(c-a,c-b))/norm(a-b)
  endfunction dpl

endmodule mat
