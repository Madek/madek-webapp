# -*- encoding : utf-8 -*-
class SnapshotsController < ApplicationController

  before_filter :pre_load
  before_filter :group_required

  def index
    @snapshots = Snapshot.all
    respond_to do |format|
      format.html
    end
  end

  def show
    respond_to do |format|
      format.html
      format.tms { render :xml => MediaResource.to_tms_doc(@snapshot) }
    end
  end
  
  def destroy
    @snapshot.destroy
    redirect_to snapshots_path
  end

###########################################################

  # Reponsible for the export of snapshots of media entries into a zipfile with xml file, for tms (The Museum System)
  # /snapshots/export?media_entry_ids[]=1&media_entry_ids[]=2
  def export
    @snapshots = Snapshot.find(params[:snapshot_ids])

    all_good = true
    clxn = []

    @snapshots.each do |snapshot|
      xml = MediaResource.to_tms_doc(snapshot)

      # not providing the full filename of the media_file to be zipped,
      # since it will be provided to the 3rd party receiving system in the accompanying XML
      # however we do apparently need to supply the suffix for the file. hence the unoptimsed nonsense below.
      file_ext = snapshot.media_file.filename.split(".").last
      filetype_extension = ".#{file_ext}" if KNOWN_EXTENSIONS.any? {|e| e == file_ext } #OPTIMIZE
      filetype_extension ||= ""
      timestamp = Time.now.to_i # stops racing below
      filename = [snapshot.id, timestamp ].join("_")
      media_filename  = filename + filetype_extension
      xml_filename    = filename + ".xml"
      path = snapshot.updated_resource_file

      clxn << [ xml, media_filename, xml_filename, path ] if path
      all_good = false unless path
    end

#    zip = xml+file

    if all_good
      race_free_filename = ["snapshot", rand(Time.now.to_i).to_s].join("_") + ".zip" # TODO handle user-provided filename
      Zip::ZipOutputStream.open("#{ZIP_STORAGE_DIR}/#{race_free_filename}") do |zos|
        clxn.each do |snapshot|
          xml, filename, xml_filename, path = snapshot

          zos.put_next_entry(filename)
          zos.print IO.read(path)
          zos.put_next_entry(xml_filename)
          zos.print xml
        end # snapshot
      end # zos

      send_file File.join(ZIP_STORAGE_DIR, race_free_filename), :type => "application/zip"
    else
      flash[:error] = "There was a problem creating the files(s) for export"
      redirect_to snapshots_path # TODO correct redirect path.
    end
  end

###########################################################

  private

  def group_required
    # OPTIMIZE
    unless current_user.groups.is_member?("MIZ-Archiv")
      flash[:error] = "The function you wish to use is only available to archivist users"
      redirect_to root_path
    end
  end

  def pre_load
    @snapshot = Snapshot.find(params[:id]) unless params[:id].blank?
  end

end
