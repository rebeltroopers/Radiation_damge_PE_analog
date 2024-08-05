      program extract_config
      implicit none

      double precision, allocatable :: r(:,:)
      double precision :: xlo, xhi, ylo, yhi, zlo, zhi, xy, xz, yz

      integer, allocatable :: attype(:)
      integer, allocatable :: idStruct(:)
      integer :: natom, natomStruct
      integer :: startframe, endframe, frame
      integer :: globalIndex, frameStruct
      integer :: index, ii, jj
      integer :: i, j, k

      character*2, allocatable :: typelist(:)

      character*100 :: fin

!!!!! Set Parameters !!!!!

      open(20,file='control.txt')
      read(20,*) startframe, endframe
      read(20,*) fin
      close(20)

!!!!! Get Structure Atom IDs !!!!!

      open(20,file='struct.txt')
      read(20,*)
      read(20,*) globalIndex, frameStruct
      read(20,*)
      read(20,*) natomStruct
      read(20,*)

      allocate (idStruct(natomStruct))

      do i=1,natomStruct
        read(20,*) idStruct(i)
      enddo

!!!!! Allocate Working Arrays !!!!!

      open(21,file=fin)

      read(21,*)
      read(21,*) !step
      read(21,*)
      read(21,*) natom
      close(21)

      allocate (r(natom,3))
      allocate (attype(natom))

!!!!! Get Target Frame !!!!!

      open(21,file=fin)

      do frame=startframe,frameStruct

        !!!!! Get Coordinates !!!!!
        read(21,*)
        read(21,*) !step
        read(21,*)
        read(21,*) !natom
        read(21,*)
        read(21,*) xlo, xhi !, xy
        read(21,*) ylo, yhi !, xz
        read(21,*) zlo, zhi !, yz
        read(21,*)

        do i=1,natom
          read(21,*) index, attype(index), (r(index,j),j=1,3)
        enddo

      enddo

      close(21)

!!!!! Print Target Configuaration !!!!!

      open(30,file='struct.lammpstrj')
      write(30,3001)
      write(30,3002) 0
      write(30,3003)
      write(30,3004) natomStruct
      write(30,3005)
      write(30,3006) xlo, xhi !, xy
      write(30,3007) ylo, yhi !, xz
      write(30,3008) zlo, zhi !, yz
      write(30,3009)

3001  format('ITEM: TIMESTEP')
3002  format(I12)
3003  format('ITEM: NUMBER OF ATOMS')
3004  format(I12)
3005  format('ITEM: BOX BOUNDS pp pp pp')
!3005  format('ITEM: BOX BOUNDS xy xz yz pp pp pp')
3006  format(3ES20.8)
3007  format(3ES20.8)
3008  format(3ES20.8)
3009  format('ITEM: ATOMS id type xu yu zu')

      do i=1,natomStruct
        write(30,3010) idStruct(i), attype(idStruct(i)), (r(idStruct(i),j),j=1,3)
3010    format(2I12,3ES20.8)
      enddo

      close(30)

!!!!! End Program !!!!!

      end





