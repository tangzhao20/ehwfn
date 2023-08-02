! Calculate the e-h pair participation ratio of exciton states
! PDeh^S(w)=sum_vck(AvckS^2*delta(Eck-Evk-w))
! We use a gaussian smearing in practice

! input: nwstates, iwstates
! read from files: eigenvectors, eqp.dat
! write to files: pdeh_istate.dat

program pdeh
  use typedefs
  use nrtype
  implicit none
  integer :: ns, nv, nc, nk, ie, ik, ic, iv, is, ij, iw
#ifdef CPLX
  complex(dpc), allocatable :: Ae(:,:,:,:) ! ns, nv, nc, nk
#else
  real(dp), allocatable :: Ae(:,:,:,:) ! ns, nv, nc, nk
#endif
  real(dp), allocatable :: energy(:), Asum(:)! j%ne
  logical, allocatable :: lwdos(:) ! j%ne
  real(dp), allocatable :: Ec(:,:) ! nc, nk
  real(dp), allocatable :: Ev(:,:) ! nv, nk
  real(dp), allocatable :: kk(:,:) ! 3, nk
  real(dp), allocatable :: fout(:), eout(:) ! nj=5000
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

  allocate(lwdos(jobs%ne))
  lwdos=.false.
  do iw =1, jobs%nwstates
    lwdos(jobs%iwstates(iw))=.true.
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
  allocate(fout(5000))
  allocate(eout(5000))

  do ij = 1, 5000
    eout(ij)=dble(ij-1)*2.d-3
  enddo ! ij

  Asum=0.d0

  iw=0
  do ie = 1, jobs%ne
    if (lwdos(ie) .eqv. .false.) then
      read(10) ! energy(ie)
      read(10) ! Aread(:)
      cycle
    endif
    iw=iw+1
    fout=0.d0
    read(10) energy(ie)
    read(10) Ae
    do ik = 1, nk
      do ic = 1, nc
        do iv = 1, nv
          do is = 1, ns
#ifdef CPLX
            Avcke = Ae(is,iv,ic,ik) * conjg(Ae(is,iv,ic,ik))
#else
            Avcke = Ae(is,iv,ic,ik) **2
#endif
            Asum(iw)=Asum(iw)+Avcke
            
            do ij = 1, 5000
!              xx=Ec(ic,ik)-Ev(iv,ik)-eout
              fout(ij)=fout(ij)+Avcke*0.3989422804014326779399/jobs%sigma*exp(-0.5*((Ec(ic,ik)-Ev(iv,ik)-eout(ij))/jobs%sigma)**2)
            enddo ! ij
          enddo ! is
        enddo ! iv
      enddo ! ic
    enddo ! ik

    write(filename,'(a,i0,a)') "pdeh_",ie,".dat"
    open(unit=16,file=filename,form="formatted",status="replace")
    do ij = 1, 5000
      write(16,'(f7.3,f18.9)') eout(ij), fout(ij)
    enddo ! ij
    close(16)
  enddo ! ie

  close(10)
  deallocate(Ae)

  if (maxval(Asum)<1.d0+1.d-6 .and. minval(Asum)>1.d0-1.d-6) then
    write(881,*)"AvckS normalization checked, sum_vck(|AvckS|^2)=1"
  else
    write(881,*)"AvckS is not normalized, sum_vck(|AvckS|^2) /= 1"
    do iw = 1, jobs%nwstates
      write(881,"(i6,f9.5)") iw,Asum(iw)
    enddo ! ie
    call die("AvckS is not normalized")
  endif
  deallocate(Asum)

  deallocate(Ev)
  deallocate(Ec)
  deallocate(kk)
  deallocate(energy)
  write(881,*) 
  call date_time(cdate, ctime)
  write(881,'(a,a11,1x,a14)') " End Time: ", cdate, ctime
endprogram pdeh
