! Calculate the k-dependent pair amplitude of exciton states
! AS(k)^2=sum_vc(|AvckS|^2)
! or the real/imaginary part separately (doesn`t seem to work yet)
! AS_real(k)=sum_vc(real(AvckS))
! AS_imag(k)=sum_vc(imag(AvckS))

! input: nwstates, iwstates
! read from files: eigenvectors eqp.dat
! write to files: ewfn_istate.dat

program ewfn
  use typedefs
  use nrtype
  implicit none
  integer :: ns, nv, nc, nk, ie, ik, ic, iv, is, iw
#ifdef CPLX
  complex(dpc), allocatable :: Ae(:,:,:,:) ! ns, nv, nc, nk
  complex(dpc), allocatable :: fwfn(:) ! nk
#else
  real(dp), allocatable :: Ae(:,:,:,:) ! ns, nv, nc, nk
  real(dp), allocatable :: fwfn(:) ! nk
#endif
  real(dp), allocatable :: fwfn2(:) ! nk
  real(dp), allocatable :: energy(:), Asum(:)! j%ne
  logical, allocatable :: lwwfn(:) ! j%ne
  real(dp), allocatable :: Ec(:,:) ! nc, nk
  real(dp), allocatable :: Ev(:,:) ! nv, nk
  real(dp), allocatable :: kk(:,:) ! 3, nk
  real(dp) :: Avcke
  type(joblist) :: jobs
  integer :: ierr
  character(len=80) :: filename
  character(len=11) :: cdate
  character(len=14) :: ctime

  open(unit=881,file="out.dat",status="replace")
  call date_time(cdate, ctime)
  write(881,'(a,a11,1x,a14)') " Start Time: ", cdate, ctime

  call readin(jobs)
  if (jobs%nwstates .eq. 0) then
    call die("jobs%nwstates=0. need input")
  endif
  jobs%ne=maxval(jobs%iwstates)

  write(881,'(a)') " change ne to max(iwstates) "
  write(881,'(a,i0)') " ne = ", jobs%ne
  write(881,'(a,l1)') " lsquare = ", jobs%lsquare


  allocate(lwwfn(jobs%ne))
  lwwfn=.false.
  do iw =1, jobs%nwstates
    lwwfn(jobs%iwstates(iw))=.true.
  enddo ! iw
    
  write(881,*)
  write(881,*) "reading file eigenvectors headers"
  open(unit=10,file="eigenvectors",form='unformatted',status='old')

  read(10) ns
  read(10) nv
  read(10) nc
  read(10) nk

  write(881,'(a,i0)') " ns = ", ns
  write(881,'(a,i0)') " nv = ", nv
  write(881,'(a,i0)') " nc = ", nc
  write(881,'(a,i0)') " nk = ", nk

  allocate(kk(3,nk))
  read(10) kk(:,:) ! kpoints

  allocate(Ec(nc,nk))
  allocate(Ev(nv,nk))
  call readeqp(jobs,nv,nc,nk,Ec,Ev,kk)

  write(881,*)
  write(881,*) "reading file eigenvectors"

  allocate(Ae(ns,nv,nc,nk))
  allocate(energy(jobs%ne))
  allocate(Asum(jobs%nwstates))

  if (jobs%lsquare) then
    allocate(fwfn2(nk))
  else ! jobs%lsquare = .false.
    allocate(fwfn(nk))
  endif ! jobs%lsquare

  Asum=0.d0
  iw=0
  do ie = 1, jobs%ne
    if (lwwfn(ie) .eqv. .false.) then
      read(10) ! energy(ie)
      read(10) ! Aread(:)
      cycle
    endif
    iw=iw+1
    if (jobs%lsquare) then

      fwfn2=0.d0
    else ! jobs%lsquare = .false.
#ifdef CPLX
      fwfn=(0.d0,0.d0)
#else
      fwfn=0.d0
#endif
    endif ! jobs%lsquare

    read(10) energy(ie)
    read(10) Ae
    if (jobs%lsquare) then
      do ik = 1, nk
        do ic = 1, nc
          do iv = 1, nv
            do is = 1, ns
#ifdef CPLX
              Avcke = Ae(is,iv,ic,ik) * conjg(Ae(is,iv,ic,ik))
#else
              Avcke = Ae(is,iv,ic,ik)**2
#endif
              fwfn2(ik) = fwfn2(ik) + Avcke
              Asum(iw)=Asum(iw)+Avcke
            enddo ! is
          enddo ! iv
        enddo ! ic
      enddo ! ik
    else ! jobs%lsquare  .eqv.  .false.
      do ik = 1, nk
        do ic = 1, nc
          do iv = 1, nv
            do is = 1, ns
#ifdef CPLX
              Avcke = Ae(is,iv,ic,ik) * conjg(Ae(is,iv,ic,ik))
#else
              Avcke = Ae(is,iv,ic,ik)**2
#endif
              fwfn(ik) = fwfn(ik) + Ae(is,iv,ic,ik)
              Asum(iw)=Asum(iw)+Avcke
            enddo ! is
          enddo ! iv
        enddo ! ic
      enddo ! ik
    endif ! jobs%lsquare


    write(filename,'(a,i0,a)') "ewfn_",ie,".dat"
    open(unit=16,file=filename,form="formatted",status="replace")
    if (jobs%lsquare) then
      write(16,'(a)') "# kx ky kz AS^2(k)"
      do ik = 1, nk
        write(16,'(3f10.6,f18.9)') kk(:,ik), fwfn2(ik)
      enddo ! ik
    else ! jobs%lsquare = .false.
#ifdef CPLX
      write(16,'(a)') " kx ky kz real(AS(k)) imag(AS(k)"
      do ik = 1, nk
        write(16,'(3f10.6,f18.9)') kk(:,ik), real(fwfn(ik)), aimag(fwfn(ik))
      enddo ! ik
#else
      write(16,'(a)') " kx ky kz AS(k)"
      do ik = 1, nk
        write(16,'(3f10.6,f18.9)') kk(:,ik), fwfn(ik)
      enddo ! ik
#endif
      close(16)
    endif ! jobs%lsquare
  enddo ! ie

  close(10)
  deallocate(Ae)

  if (maxval(Asum)<1.d0+1.d-6 .and. minval(Asum)>1.d0-1.d-6) then
    write(881,*)"AvckS normalization checked, sum_vck(|AvckS|^2)=1"
  else
    write(881,*)"AvckS is not normalized, sum_vck(|AvckS|^2) /= 1"
    do iw = 1, jobs%nwstates
      write(881,"(i6,f9.5)") jobs%iwstates(iw),Asum(iw)
    enddo ! ie
    call die("AvckS is not normalized")
  endif
  deallocate(Asum)

  if (jobs%lsquare) then
    deallocate(fwfn2)
  else ! jobs%lsquare = .false.
    deallocate(fwfn)
  endif ! jobs%lsquare
  deallocate(Ev)
  deallocate(Ec)
  deallocate(kk)
  deallocate(energy)
  write(881,*) 
  call date_time(cdate, ctime)
  write(881,'(a,a11,1x,a14)') " End Time: ", cdate, ctime
endprogram ewfn
