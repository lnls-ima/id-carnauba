
import os
import time
import numpy as np
import imaids

device = imaids.models.DeltaCarnauba()

dp = device.period_length/4
dcp = 0
dgh = 0
field_phase = 90
polarization_name = 'LHCircularPolarization'
device_name = 'DeltaCarnauba'

xmin = -4.5
xmax = 4.5
xstep = 0.5

ymin = -2.5
ymax = 2.5
ystep = 0.5

zmin = -800
zmax = 800
zstep = 0.5

energy = 3
rkstep = np.pi/4

directory = os.path.dirname(os.path.abspath(__file__))

# dgvs = [0, -device.period_length/4, -3*device.period_length/8]
# disp_names = ['', 'dGV', 'dGV']

dgvs = [-3*device.period_length/8]
disp_names = ['dGV']

imaids.functions.set_len_tol()

for i in range(len(dgvs)):
    t0 = time.time()

    dgv = dgvs[i]
    displacement_name = disp_names[i]

    device.set_cassete_positions(dp=dp, dcp=dcp, dgv=dgv, dgh=dgh)
    device.solve()

    date = time.strftime('%Y-%m-%d', time.localtime())

    bx_amp, by_amp, _, _ = device.calc_field_amplitude()
    kh, kv = imaids.functions.calc_deflection_parameter(
        bx_amp, by_amp, device.period_length)

    start_len = sum(device.start_blocks_distance) + sum(
        device.start_blocks_length)
    end_len = sum(device.end_blocks_distance) + sum(device.end_blocks_length)
    magnet_len = start_len + device.nr_periods*device.period_length + end_len

    header = imaids.functions.get_file_header_delta(
        date, device_name, polarization_name, kh, kv,
        device.gap, device.period_length, magnet_len, field_phase,
        dp=device.dp, dcp=device.dcp, dgv=device.dgv, dgh=device.dgh)

    x_list = np.linspace(xmin, xmax, int((xmax - xmin)/xstep) + 1)
    y_list = np.linspace(ymin, ymax, int((ymax - ymin)/ystep) + 1)
    z_list = np.linspace(zmin, zmax, int((zmax - zmin)/zstep) + 1)

    fieldmap = imaids.functions.get_filename(
        date, device_name, polarization_name,
        x_list, y_list, z_list, kh, kv,
        file_extension='.fld', displacement_name=displacement_name)

    print(os.path.join(directory, fieldmap))

    device.save_fieldmap(
        os.path.join(directory, fieldmap),
        x_list, y_list, z_list, header=header)

    t1 = time.time()
    print('dgv: ', dgv)
    print('calc time[s]: ', t1-t0)
