program getrf
    implicit none

    ! ---- model / loading parameters (edit here) ----
    real(8), parameter :: total_disp = 14.0d0     ! end displacement of the half model [mm]
    real(8), parameter :: half_len   = 40.0d0     ! half-length of the model [mm]
    real(8), parameter :: area_full  = 200.0d0    ! full cross-section 25 x 8 [mm^2]
    real(8), parameter :: sym_factor = 4.0d0      ! Nload face is 1/4 of the section
    real(8), parameter :: dt_out     = 0.01d0     ! output time-point spacing (time 0..1)

    integer :: ios
    integer :: i
    real(8) :: forcex, disp
    character(len=256) :: input_file, output_file
    character(len=1) :: skip

    input_file  = 'tensile.dat'
    output_file = 'force.dat'

    open(unit=10, file=input_file, status='old', action='read', iostat=ios)
    if (ios /= 0) then
        write(*,*) 'Error opening input file: ', trim(input_file)
        stop
    end if

    open(unit=20, file=output_file, status='replace', action='write', iostat=ios)
    if (ios /= 0) then
        write(*,*) 'Error opening output file: ', trim(output_file)
        close(10)
        stop
    end if

    ! skip header of the .dat file
    do i = 1, 9
        read(10, fmt='(a1)', iostat=ios) skip
        if (ios < 0) exit          ! end of file
        if (ios > 0) then
            write(*,*) 'Error reading input file.'
            exit
        end if
    end do

    ! first output is at time = dt_out, i.e. a displacement of dt_out*total_disp
    disp = dt_out * total_disp

    do
        read(10, *, iostat=ios) forcex
        if (ios < 0) exit          ! end of file
        if (ios > 0) then
            write(*,*) 'Error reading input file.'
            exit
        end if

        ! columns: total force [N], engineering strain [%], engineering stress [MPa]
        write(20,*) forcex, (disp/half_len)*100.0d0, sym_factor*forcex/area_full

        disp = disp + dt_out * total_disp     ! FIX: was disp + 0.01

        ! skip the lines between successive RF blocks
        do i = 1, 6
            read(10, fmt='(a1)', iostat=ios) skip
            if (ios < 0) exit
            if (ios > 0) then
                write(*,*) 'Error reading input file.'
                exit
            end if
        end do
        if (ios /= 0) exit
    end do

    close(10)
    close(20)

    write(*,*) 'done'
    write(*,*) 'Output file: ', trim(output_file)

end program getrf
