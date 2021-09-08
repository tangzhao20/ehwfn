subroutine readeqp(jobs,nv,nc,nk,Ec,Ev,kk)
  use mat
  use typedefs
  use nrtype
  implicit none
  integer, intent(in) :: nk,nc,nv
  integer :: ik, ic, iv, tmp_n
  real(dp) :: tmp_kk(3), kshift(3)
  real(dp), intent(in) :: kk(3,nk)

  real(dp), intent(out) :: Ec(nc,nk) ! nc, nk
  real(dp), intent(out) :: Ev(nv,nk) ! nv, nk

  type(joblist), intent(in) :: jobs

  character(len=80) :: something
  integer :: ierr

  open(unit=13,file="eqp.dat",form="formatted",status="old")
  open(unit=14,file="eqp_q.dat",form="formatted",status="old",iostat=ierr)
  if (ierr==0) then ! eqp_q exist
    write(881,*)
    write(881,*) "reading file eqp.dat for Eck"
  
    do ik = 1, nk
      read(13,*)tmp_kk(:), tmp_n
      if (sum(dabs(kk(:,ik)-tmp_kk))>1.d-6) then
        call die("k points of eigenvectors and eqp.dat doesn`t match")
      endif
      if (nc>tmp_n) then
        call die("more conduction bands in eigenvectors than eqp.dat")
      endif
      do ic = nc+1, tmp_n, 1
        read(13,*) ! padding to tmpnc
      enddo ! ic
      do ic = 1, nc
        read(13,*) something, something, something, Ec(ic,ik)
      enddo ! ic
    enddo ! ik
  
    write(881,*)
    write(881,*) "reading file eqp_q.dat for Evk"  
    do ik = 1, nk
      read(14,*)tmp_kk(:), tmp_n
      if (ik==1) then
        kshift=tmp_kk-kk(:,1)
        write(881,'(a,3f9.5)') " kshift = ", kshift
      endif ! ik==1
      if (nv>tmp_n) then
        call die("more valence bands in eigenvectors than eqp_q.dat")
      endif
      do iv = nv, 1, -1
  !      read(14,*) something, something, something, Ev(iv,ik2)
        read(14,*) something, something, something, Ev(iv,ik)
      enddo ! iv
      do iv = nv+1, tmp_n, 1
        read(14,*) ! padding to tmp_n
      enddo ! iv
    enddo ! ik
    close(14)
  
  
    if (jobs%lwkpoints .or. jobs%lwkpoints) then
      write(881,*)
    endif
    if (jobs%lwkpoints) then
      write(881,"(a)") " klist: "
    endif
    do ik = 1, nk
      if (jobs%lwkpoints) then
        write(881,'(i6,3(f10.6))')ik,kk(:,ik)
      elseif (jobs%lwbands) then
        write(881,'(i6)')ik
      endif
      if (jobs%lwbands) then
        write(881,*) "   Ev:"
        do iv = nv, 1, -1
          write(881,'(f18.9)')Ev(iv,ik)
        enddo
        write(881,*) "   Ec:"
        do ic = 1, nc
          write(881,'(f18.9)')Ec(ic,ik)
        enddo
      endif
    enddo ! ik
  else
    write(881,*)
    write(881,*) "reading file eqp.dat for Eck and Evk"
  
    do ik = 1, nk
      read(13,*)tmp_kk(:), tmp_n
      if (.not. equal(kk(:,ik),tmp_kk)) then
        call die("k points of eigenvectors and eqp.dat doesn`t match")
      endif
      if (nc+nv/=tmp_n) then
        call die("Nbands in eigenvectors does not match eqp.dat")
      endif
      do iv = nv, 1, -1
        read(13,*) something, something, something, Ev(iv,ik)
      enddo ! iv
      do ic = 1, nc
        read(13,*) something, something, something, Ec(ic,ik)
      enddo ! ic
    enddo ! ik
     
  endif ! eqp_q exist

  close(13)

endsubroutine readeqp
