module Orchestration::Metadata
  extend ActiveSupport::Concern

  included do
    after_validation :validate_metadata, :queue_metadata
    before_destroy :queue_metadata_destroy

    # required for pxe template url helpers TBS
    include Rails.application.routes.url_helpers
  end

  def metadata?
     p "************** metadata?"
     managed? # and ip present?
#     false  # TBS!!
  end


  protected

  # Sets metadata for the host
  # +returns+ : Boolean true on success
  def setMetadata
    logger.info "Add the metadata configuration for #{name}"
    p tftp.inspect
    p self.inspect
    metadata.set ip, :pxeconfig => generate_pxe_template
  end

  # Removes metadata for the host
  # +returns+ : Boolean true on success
  def delMetadata
    logger.info "Delete the metadata configuration for #{name}"
    metadata.delete ip
  end

  private

  def validate_metadata
    # TBS
    p "********* validate metadata"
    return unless metadata?
    return unless operatingsystem
    return if Rails.env == "test"
  end


  def queue_metadata
    p "********* queue metadata"
    return unless metadata? and errors.empty?
    new_record? ? queue_metadata_create : queue_metadata_update
  end

  def queue_metadata_create
    p "********* queue metadata create"
    queue.create(:name => _("metadata Settings for %s") % self, :priority => 20,
                 :action => [self, :setMetadata])
  end

  def queue_metadata_update
    p "********* queue metadata update"
    set_metadata = false
    # we switched build mode
    set_metadata = true if old.build? != build?
    
    # TBS - if other metadata attributes changed?
    
    # IP address changed
    if ip != old.ip
      set_metadata = true
      # clean up old metadata file
      if old.metadata?
        queue.create(:name => _("Remove old metadata Settings for %s") % old, :priority => 19,
                     :action => [old, :delMetadata])
      end
    end
    queue_metadata_create  if set_metadata
  end

  def queue_metadata_destroy
    p "********* queue metadata destroy"
    return unless metadata? and errors.empty?
    return true if jumpstart?
    queue.create(:name => _("metadata Settings for %s") % self, :priority => 20,
                 :action => [self, :delMetadata])
  end

end
