

i=1 ; select obs
obs_nn= STRCOMPRESS(string(i+1),/REMOVE_ALL)

; load obs details, name, + stop, start times
details = rd_tfile('details.txt',3) ; text file containing details of all observations
obs_details=details[*,i]
obs_name=obs_details[0] ; for saving
start_sample_time=date_conv((obs_details[1]),'R') ; convert to date_time to real numbers
end_sample_time=date_conv((obs_details[2]),'R')
obs='/Users/brandonlpanos/papers/AIA_IRIS/data/'+obs_name

; read raster details for ploting the rasters span
path_to_raster_file = obs + '/raster/'
rasterfiles = file_search(path_to_raster_file + '*raster*fits',count=nraster)
read_iris_l2,rasterfiles[0],hdrs,dat

; iterate over different SJI's
sji_data_paths = FILE_SEARCH(obs + '/sji/*')
for ii=0,(size(sji_data_paths))[1]-1 do begin
    sji_path=sji_data_paths[ii]
    ; get string for filter
    splits = STRSPLIT(sji_path,'_',/EXTRACT)
    filter = splits[9] + '_' + splits[10]
    ; read in headers and data
    read_iris_l2,sji_path,sjihdrs,images
    ; images = IRIS_DUSTBUSTER(sjihdrs,images,bpaddress,clean_values,/run) ; clean dust from SJI
    times = sjihdrs.date_obs
    t_dim = size(times)
    t_dim = t_dim[1]
    times_r = List()
    for t=0, t_dim-1 do begin
        times_r.Add, date_conv(times[t],'R')
    endfor
    times_r = times_r.ToArray()

    ; set up dimensions
    shape = size(images)
    x_dim = shape[1]
    y_dim = shape[2]
    n_frames = shape[3]
    n_steps = size(dat)
    n_steps = n_steps[3]

;----------------------------- plotting ----------------------------------------
    target_time = date_conv('2014-11-07T09:54:40.270', 'R')
    nearest = min(abs(times_r - target_time), frame)

    set_plot,'PS'
    device,filename='/Users/brandonlpanos/papers/AIA_IRIS/images/'+obs_nn+'_'+filter+'_'+STRCOMPRESS(string(frame),/REMOVE_ALL)+'.eps',/encaps,xsize=15,ysize=15,/color
    !p.color=0
    !p.background=255
    !p.charsize = 1
    loadct,0
    tmpp = where(images[*,*,frame] eq -200)
    img = (images[*,*,frame]>0)^.3
    img[tmpp] = mean(img)
    index2map,sjihdrs[frame],img,map
    get_map_coord,map,xcoord,ycoord
    plot_map,map,ticklen=-.02, TITLE = 'Date-Time: ' + times[frame]
    ; IRIS slit span
    slpos = xcoord[sjihdrs[frame].sltpx1ix-1,0] - sjihdrs[frame].pztx + hdrs.pztx
    clr='black'
    if date_conv(times[frame],'R') ge start_sample_time and date_conv(times[frame],'R') le end_sample_time then clr='green'
    plots,slpos[0],!y.crange,lines=0,color=cgcolor(clr),thick=1
    plots,slpos[n_steps-1],!y.crange,lines=0,color=cgcolor(clr),thick=1
    ; xyouts,.72,.80,filter,/norm,charsize=1.2, color=cgcolor('white')
    ; xyouts,.15,.80,'PF Obs '+obs_nn ,/norm,charsize=1.2, color=cgcolor('white')
    xyouts,.72,.77,filter,/norm,charsize=1.2, color=cgcolor('white')
    xyouts,.15,.77,'PF Obs '+obs_nn ,/norm,charsize=1.2, color=cgcolor('white')
    ; xyouts,.72,.80,filter,/norm,charsize=1.2, color=cgcolor('white')
    ; xyouts,.15,.80,'PF Obs '+obs_nn ,/norm,charsize=1.2, color=cgcolor('white')

    device,/close
    set_plot,'x'

endfor

END