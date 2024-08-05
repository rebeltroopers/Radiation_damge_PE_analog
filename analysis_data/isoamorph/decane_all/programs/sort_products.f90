      program compute_energy
      implicit none

!!!!!!!!!!!!!!!!!!! Interface Declaration !!!!!!!!!!!!!!!!!!!

      interface

      subroutine hpsort_eps_epw(n, ra, ind, eps)
        integer, intent(in) :: n
        double precision, allocatable, intent(in out), dimension(:) :: ra
        integer, allocatable, intent(in out), dimension(:) :: ind
        double precision, intent(in) :: eps
      end subroutine hpsort_eps_epw

      end interface

!!!!!!!!!!!!!!!!!!! Main Program !!!!!!!!!!!!!!!!!!!

      double precision, allocatable :: mass(:)
      double precision, allocatable :: structureMass(:)
      double precision :: molmass

      integer, allocatable :: reactiveSI(:)
	  integer, allocatable :: bondsperatom(:)
      integer, allocatable :: ind(:)
	  integer, allocatable :: comp(:)
      integer :: nstructuretypes, ntype, natom, natommax  
      integer :: i, j, k, index, dumInt

      character*2, allocatable :: typelist(:)
	  character*2, allocatable :: el(:)
	  character*200 :: flnm

!!!!! Get Parameters !!!!!

	  natommax = 1000

	  !Get number of unique structures
	  open(20,file='tmp.txt')
      read(20,*) nstructuretypes
	  close(20)
	  
	  !Get atom types
      open(20,file='inputs/bond_defs.txt')
      read(20,*)
      read(20,*) ntype

      allocate (typelist(ntype))

      read(20,*)
      do i=1,ntype
        read(20,*) index, typelist(index)
      enddo
      close(20)

      allocate (mass(ntype))

      do i=1,ntype
        if(typelist(i).eq.'H')  mass(i) = 1.0079d0
        if(typelist(i).eq.'C')  mass(i) = 12.011d0
        if(typelist(i).eq.'N')  mass(i) = 14.007d0
        if(typelist(i).eq.'O')  mass(i) = 15.999d0
		if(typelist(i).eq.'Si') mass(i) = 28.086d0
        if(typelist(i).eq.'S')  mass(i) = 32.065d0
      enddo
	  
	  allocate ( el(natommax) )
      allocate ( bondsperatom(natommax) )

!!!!! Get Data !!!!!

      allocate (structureMass(nstructuretypes))
      allocate (ind(nstructuretypes))
      allocate (comp(ntype))
	  allocate (reactiveSI(nstructuretypes))

	  reactiveSI = 0 

      do i=1,nstructuretypes
	  
	    ind(i) = i
	    index = i
		
		if(index.ge.0     .and. index.lt.10)     write(flnm,9001) index 
		if(index.ge.10    .and. index.lt.100)    write(flnm,9002) index 
		if(index.ge.100   .and. index.lt.1000)   write(flnm,9003) index 
		if(index.ge.1000  .and. index.lt.10000)  write(flnm,9004) index 
		if(index.ge.10000 .and. index.lt.100000) write(flnm,9005) index 
	 
9001	format('outputs/lib.structures/graphs/struct.',I1,'.txt')
9002	format('outputs/lib.structures/graphs/struct.',I2,'.txt')	
9003	format('outputs/lib.structures/graphs/struct.',I3,'.txt')	
9004	format('outputs/lib.structures/graphs/struct.',I4,'.txt')	
9005	format('outputs/lib.structures/graphs/struct.',I5,'.txt')		 
	  
        open(30,file=flnm)
		read(30,*)
		read(30,*)
		read(30,*)
		read(30,*) natom, (comp(j),j=1,ntype)
		read(30,*)
		
		do j=1,natom 
		  read(30,*) dumINT, el(j), bondsperatom(j)
		enddo 
		
		close(30)
		
		!Determine molecular mass 
        molmass = 0.0d0
        do j=1,ntype
          molmass = molmass + dfloat(comp(j))*mass(j)
        enddo	
		structureMass(i) = molmass 
		
		!Determine if there are reactive Silicon sites (i.e., Si with bonds =/= 4)
		do j=1,natom 
		  if(el(j).eq.'Si')then 
		    if(bondsperatom(j).ne.4) reactiveSI(i) = 1 
		  endif 
		enddo 
		
      enddo

!!!!! Sort by Coefficient Value !!!!!

      call hpsort_eps_epw(nstructuretypes, structureMass, ind, 1.0d-6)

!!!!! Print Sorted Average Energies !!!!!

      open(40,file='sort_output.txt')
      write(40,4000)
4000  format('#Index  StructureType  Mass(au)  ReactiveSI?')

      do i=1,nstructuretypes
        write(40,4001) i, ind(i), structureMass(i), reactiveSI(ind(i))
4001    format(2I6,F20.8,I6)
      enddo

      close(40)

!!!!! End !!!!!

      end 

!
  ! Copyright (C) 2010-2016 Samuel Ponce', Roxana Margine, Carla Verdi, Feliciano Giustino
  ! Copyright (C) 2007-2009 Jesse Noffsinger, Brad Malone, Feliciano Giustino
  !
  ! This file is distributed under the terms of the GNU General Public
  ! License. See the file `LICENSE' in the root directory of the
  ! present distribution, or http://www.gnu.org/copyleft.gpl.txt .
  !
  ! Adapted from flib/hpsort_eps
  !---------------------------------------------------------------------
  subroutine hpsort_eps_epw (n, ra, ind, eps)
  !---------------------------------------------------------------------
  ! sort an array ra(1:n) into ascending order using heapsort algorithm,
  ! and considering two elements being equal if their values differ
  ! for less than "eps".
  ! n is input, ra is replaced on output by its sorted rearrangement.
  ! create an index table (ind) by making an exchange in the index array
  ! whenever an exchange is made on the sorted data array (ra).
  ! in case of equal values in the data array (ra) the values in the
  ! index array (ind) are used to order the entries.
  ! if on input ind(1)  = 0 then indices are initialized in the routine,
  ! if on input ind(1) != 0 then indices are assumed to have been
  !                initialized before entering the routine and these
  !                indices are carried around during the sorting process
  !
  ! no work space needed !
  ! free us from machine-dependent sorting-routines !
  !
  ! adapted from Numerical Recipes pg. 329 (new edition)
  !
  !use kinds, ONLY : DP
  implicit none
  !-input/output variables
  integer, intent(in)   :: n
  double precision, intent(in)  :: eps
  integer, allocatable, intent(in out) :: ind(:)
  double precision, allocatable, intent(in out) :: ra(:)
  !-local variables
  integer :: i, ir, j, l, iind
  double precision :: rra
!
  ! initialize index array
  IF (ind (1) .eq.0) then
     DO i = 1, n
        ind (i) = i
     ENDDO
  ENDIF
  ! nothing to order
  IF (n.lt.2) return
  ! initialize indices for hiring and retirement-promotion phase
  l = n / 2 + 1

  ir = n

  sorting: do

    ! still in hiring phase
    IF ( l .gt. 1 ) then
       l    = l - 1
       rra  = ra (l)
       iind = ind (l)
       ! in retirement-promotion phase.
    ELSE
       ! clear a space at the end of the array
       rra  = ra (ir)
       !
       iind = ind (ir)
       ! retire the top of the heap into it
       ra (ir) = ra (1)
       !
       ind (ir) = ind (1)
       ! decrease the size of the corporation
       ir = ir - 1
       ! done with the last promotion
       IF ( ir .eq. 1 ) then
          ! the least competent worker at all !
          ra (1)  = rra
          !
          ind (1) = iind
          exit sorting
       ENDIF
    ENDIF
    ! wheter in hiring or promotion phase, we
    i = l
    ! set up to place rra in its proper level
    j = l + l
    !
    DO while ( j .le. ir )
       IF ( j .lt. ir ) then
          ! compare to better underling
          IF ( hslt( ra (j),  ra (j + 1) ) ) then
             j = j + 1
          !else if ( .not. hslt( ra (j+1),  ra (j) ) ) then
             ! this means ra(j) == ra(j+1) within tolerance
           !  if (ind (j) .lt.ind (j + 1) ) j = j + 1
          ENDIF
       ENDIF
       ! demote rra
       IF ( hslt( rra, ra (j) ) ) then
          ra (i) = ra (j)
          ind (i) = ind (j)
          i = j
          j = j + j
       !else if ( .not. hslt ( ra(j) , rra ) ) then
          !this means rra == ra(j) within tolerance
          ! demote rra
         ! if (iind.lt.ind (j) ) then
         !    ra (i) = ra (j)
         !    ind (i) = ind (j)
         !    i = j
         !    j = j + j
         ! else
             ! set j to terminate do-while loop
         !    j = ir + 1
         ! endif
          ! this is the right place for rra
       ELSE
          ! set j to terminate do-while loop
          j = ir + 1
       ENDIF
    ENDDO
    ra (i) = rra
    ind (i) = iind

  END DO sorting
contains

  !  internal function
  !  compare two real number and return the result

  logical function hslt( a, b )
    double precision :: a, b
    IF( dabs(a-b) <  eps ) then
      hslt = .false.
    ELSE
      hslt = ( a < b )
    end if
  end function hslt

  !
end subroutine hpsort_eps_epw





