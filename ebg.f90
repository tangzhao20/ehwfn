! Find the non-interacting transition energy
! Eg^S=sum_cvk((A_cvkS)^2*(Eck-Evk+q))
! Calculate the ipr of the e-h amplitude
! IPR^S=sum_cvk(AcvkS^2)^2/sum_cvk(AcvkS^4)
! Normalization condition: AcvkS^2==1
! IPR^S=1/sum_cvk(AcvkS^4)

! input: (ne)
! read from files: eigenvectors eqp.dat (eqp_q.dat) (eigenvalues.dat)
! write to files: energy.dat

program ebg
  use typedefs
  use nrtype
#ifdef HDF5
  use hdf5
#endif
  
  implicit none
  integer :: ns, nv, nc, nk, ie, ik, ic, iv, is, ix, ne_all, ncplx

  real(dp), allocatable :: energy(:) ! j%ne
  real(dp) :: Egap, Eb, ipr
  real(dp), allocatable :: Asum(:), d2(:), e_save(:)! j%ne
  real(dp), allocatable :: Ec(:,:) ! nc, nk
  real(dp), allocatable :: Ev(:,:) ! nv, nk
  real(dp), allocatable :: kk(:,:) ! 3, nk
  real(dp) :: Avcke, ipr0
  type(joblist) :: jobs
  logical :: lfile
  integer :: ierr

#ifdef HDF5
  real(dp), allocatable :: Ae_h5(:,:,:,:,:) ! ncplx, ns, nv, nc, nk
  integer(HID_T) :: file_id, data_id, dataspace_id, memspace_id ! hdf5 id
  integer(HSIZE_T) :: dims1(1), dims2(2), dims7(7), offset7(7), count7(7)
#endif

#ifdef CPLX
  complex(dpc), allocatable :: Ae(:,:,:,:) ! ns, nv, nc, nk
#else
  real(dp), allocatable :: Ae(:,:,:,:) ! ns, nv, nc, nk
#endif

  character(len=80) :: filename,something
  character(len=11) :: cdate
  character(len=14) :: ctime

  open(unit=881,file="out.dat",status="replace")
  call date_time(cdate, ctime)
  write(881,'(a,a11,1x,a14)') " Start Time: ", cdate, ctime

  call readin(jobs)
  ! if ne is given in input then read it
  ! if input doesn`t exist try reading it from eigenvalues.dat
  ! if eigenvalues.dat doesn`t exist, read it as ns*nv*nc*nk in eigenvectors

  lfile=.False.
  inquire(file="eigenvalues.dat",exist=lfile)
  if (lfile) then
    write(881,*)
    write(881,*) "eigenvalues.dat exists"
    open(unit=25,file="eigenvalues.dat",status="old")
    read(25,*) something, something, something, ne_all
    if (jobs%ne==0) then
      write(881,*) "ne is read from eigenvalues.dat"
      jobs%ne=ne_all
      write(881,'(a,i0)') " ne = ", jobs%ne
    elseif (jobs%ne>ne_all) then
      write(881,*) "ne from input is larger than from eigenvalues.dat. reset ne"
      jobs%ne=ne_all
      write(881,'(a,i0)') " ne = ", jobs%ne
    endif
     
    read(25,*)
    read(25,*)
    read(25,*)
  else
    write(881,*) "eigenvalues.dat doesn`t exist"
  endif ! lfile

  write(881,*)
#ifdef HDF5
  if (jobs%lhdf5) then
    write(881,*) "reading file eigenvectors.h5 headers"
    dims1=1
    call h5open_f(ierr)
    call h5fopen_f("eigenvectors.h5", H5F_ACC_RDONLY_F, file_id, ierr)

    call h5dopen_f(file_id, "exciton_header/params/ns", data_id, ierr)
    call h5dread_f(data_id, H5T_NATIVE_INTEGER, ns, dims1, ierr)
    call h5dclose_f(data_id, ierr)

    call h5dopen_f(file_id, "exciton_header/params/nv", data_id, ierr)
    call h5dread_f(data_id, H5T_NATIVE_INTEGER, nv, dims1, ierr)
    call h5dclose_f(data_id, ierr)

    call h5dopen_f(file_id, "exciton_header/params/nc", data_id, ierr)
    call h5dread_f(data_id, H5T_NATIVE_INTEGER, nc, dims1, ierr)
    call h5dclose_f(data_id, ierr)

    call h5dopen_f(file_id, "exciton_header/kpoints/nk", data_id, ierr)
    call h5dread_f(data_id, H5T_NATIVE_INTEGER, nk, dims1, ierr)
    call h5dclose_f(data_id, ierr)
  else
#endif
   write(881,*) "reading file eigenvectors headers"
   open(unit=10,file="eigenvectors",form='unformatted',status='old')
   read(10) ns
   read(10) nv
   read(10) nc
   read(10) nk
#ifdef HDF5
  endif
#endif

  write(881,'(a,i0)') " ns = ", ns
  write(881,'(a,i0)') " nv = ", nv
  write(881,'(a,i0)') " nc = ", nc
  write(881,'(a,i0)') " nk = ", nk

  if (lfile .and. ne_all>ns*nv*nc*nk) then
    write(881,"(a,i0,a,i0)") " Warning: ne from eigenvalues.dat ", ne_all, " > ns*nv*nc*nk ", ns*nc*nv*nk
  endif 

  if (jobs%ne==0) then
    write(881,*) "ne is calculated from ns*nv*nc*nk"
    jobs%ne=ns*nv*nc*nk
    write(881,'(a,i0)') " ne = ", jobs%ne
  elseif (jobs%ne>ns*nv*nc*nk) then
    write(881,*) "ne is larger than ns*nv*nc*nk. reset ne"
    jobs%ne=ns*nv*nc*nk
    write(881,'(a,i0)') " ne = ", jobs%ne
  endif

  if (lfile) then
    write(881,*)
    write(881,*) "reading |dipole|^2 from eigenvalues.dat"
    allocate(d2(jobs%ne))
    allocate(e_save(jobs%ne))
    do ie = 1, jobs%ne 
      read(25,*) e_save(ie), d2(ie)
    enddo
  endif ! lfile
! renormalize |dipole|^2 by nk
  d2=d2/nk
 
  allocate(kk(3,nk))
#ifdef HDF5
  if (jobs%lhdf5) then
    dims2=(/3,nk/)
    call h5dopen_f(file_id, "exciton_header/kpoints/kpts", data_id, ierr)
    call h5dread_f(data_id, H5T_NATIVE_DOUBLE, kk, dims2, ierr)
    call h5dclose_f(data_id, ierr)
  else
#endif
    read(10) kk(:,:) ! kpoints
#ifdef HDF5
  endif
#endif

  allocate(Ec(nc,nk))
  allocate(Ev(nv,nk))
  call readeqp(jobs,nv,nc,nk,Ec,Ev,kk)

  write(881,*)
  write(881,*) "reading file eigenvectors"

  allocate(Asum(jobs%ne))
  Asum=0.d0

  open(unit=15,file="energy.dat",status="replace")
  if (lfile) then
    write(15,*) "#exciton Eexciton(eV) Egap(eV) Ebinding(eV) IPR |dipole|^2"
  else
    write(15,*) "#exciton Eexciton(eV) Egap(eV) Ebinding(eV) IPR"
  endif

#ifdef CPLX
  ncplx=2
#else
  ncplx=1
#endif

  allocate(energy(ne_all))
#ifdef HDF5
  if (jobs%lhdf5) then
    ! read all energies from .h5 here
    dims1=(/ne_all/)
    call h5dopen_f(file_id, "exciton_data/eigenvalues", data_id, ierr)
    call h5dread_f(data_id, H5T_NATIVE_DOUBLE, energy, dims1, ierr)
    call h5dclose_f(data_id, ierr)
    call h5dopen_f(file_id, "exciton_data/eigenvectors", data_id, ierr)

    dims7=(/ncplx, ns, nv, nc, nk, ne_all, 1/)
    count7=(/ncplx, ns, nv, nc, nk, 1, 1/)
    dims1=product(count7)
    call h5screate_simple_f(1, dims1, memspace_id, ierr)
    allocate(Ae_h5(ncplx,ns,nv,nc,nk))
  else
#endif
    allocate(Ae(ns,nv,nc,nk))
#ifdef HDF5
  endif
#endif

  ! main loop:
  do ie = 1, jobs%ne
    Egap=0.d0
    ipr=0.d0

#ifdef HDF5
    if (jobs%lhdf5) then
      offset7=(/0, 0, 0, 0, 0, ie-1, 0/)
      call h5dget_space_f(data_id, dataspace_id, ierr)
      call h5sselect_hyperslab_f(dataspace_id, H5S_SELECT_SET_F, offset7, count7, ierr)
      call h5dread_f(data_id, H5T_NATIVE_DOUBLE, Ae_h5, dims7, ierr, memspace_id, dataspace_id)
    else
#endif
      read(10) energy(ie)
      read(10) Ae
#ifdef HDF5
    endif
#endif

    if (lfile .and. dabs(energy(ie)-e_save(ie))>1.e-4) then
      write(881,"(a,i0,a)") " Warning: ",ie," energy doesn't match"
      write(881,"(a,f10.6,a,f10.6)") "  eigenvalues.dat:",e_save(ie),"  eigenvectors:",energy(ie)
    endif

    do ik = 1, nk
      ipr0=0.d0
      do ic = 1, nc
        do iv = 1, nv
          do is = 1, ns
#ifdef HDF5
            if (jobs%lhdf5) then
#ifdef CPLX
              Avcke = Ae_h5(1,is,iv,ic,ik)**2 + Ae_h5(2,is,iv,ic,ik)**2
#else
              Avcke = Ae_h5(1,is,iv,ic,ik)**2
#endif
            else
#endif
#ifdef CPLX
              Avcke = Ae(is,iv,ic,ik) * conjg(Ae(is,iv,ic,ik))
#else
              Avcke = Ae(is,iv,ic,ik)**2
#endif
#ifdef HDF5
            endif
#endif
            Egap=Egap+Avcke*(Ec(ic,ik)-Ev(iv,ik))
            Asum(ie)=Asum(ie)+Avcke
            ipr0=ipr0+Avcke
          enddo ! is
        enddo ! iv
      enddo ! ic
      ipr=ipr+ipr0*ipr0
    enddo ! ik

    ipr=Asum(ie)*Asum(ie)/ipr

    Eb=Egap-energy(ie)
    if (Eb<-1.d-6) then
      write(881,"(a,i0,a,f9.5,a)") " Warning: ", ie, " negative Eb ", Eb, " eV"
    endif 
    if (lfile) then
      write(15,"(i6, 3f9.5,f12.5,e16.8)") ie, energy(ie), Egap, Eb, ipr, d2(ie)
    else
      write(15,"(i6, 3f9.5,f12.5)") ie, energy(ie), Egap, Eb, ipr
    endif
   
  enddo ! ie

#ifdef HDF5
  if (jobs%lhdf5) then
    call h5sclose_f(memspace_id, ierr)
    call h5sclose_f(dataspace_id, ierr)
    call h5dclose_f(data_id, ierr)
    call h5fclose_f(file_id, ierr)
    call h5close_f(ierr)
    deallocate(Ae_h5)
  else
#endif
    close(10)
    deallocate(Ae)
#ifdef HDF5
  endif
#endif
  close(15)

  write(881,*)
  if (maxval(Asum)<1.d0+1.d-6 .and. minval(Asum)>1.d0-1.d-6) then
    write(881,*)"AvckS normalization checked, sum_vck(|AvckS|^2)=1"
  else
    write(881,*)"AvckS is not normalized, sum_vck(|AvckS|^2) /= 1"
    do ie = 1, jobs%ne
      write(881,"(i6,f9.5)") ie,Asum(ie)
    enddo ! ie
    call die("AvckS is not normalized")
  endif
  deallocate(Asum)

  deallocate(energy)
  deallocate(Ev)
  deallocate(Ec)
  deallocate(kk)
  if (lfile) then
    deallocate(d2)
    deallocate(e_save)
  endif
  write(881,*) 
  call date_time(cdate, ctime)
  write(881,'(a,a11,1x,a14)') " End Time: ", cdate, ctime
endprogram ebg
