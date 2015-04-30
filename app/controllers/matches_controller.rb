class MatchesController < ApplicationController
  before_action :set_match, only: [:show, :edit, :update, :destroy]

  # GET /matches
  # GET /matches.json
  def index
    @matches = Match.all
    @match_distances = Match.find_match(current_user)
  end

  # GET /matches/1
  # GET /matches/1.json
  def show

    @conversation = Conversation.find_by_id(@match.conversation_id)
    @messages = @conversation.messages
    @message = Message.new
  end

  # GET /matches/new
  def new
    @match = Match.new
  end

  # GET /matches/1/edit
  def edit
  end

  # POST /matches
  # POST /matches.json
  def create
    @match = Match.new(match_params)
    @match.player1_id = current_user.id
    conv = Conversation.new
    conv.match_id = @match.id
    conv.save!
    @match.conversation_id = conv.id


    respond_to do |format|
      if @match.save
        format.html { redirect_to @match, notice: 'Match was successfully created.' }
        format.json { render action: 'show', status: :created, location: @match }
      else
        format.html { render action: 'new' }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matches/1
  # PATCH/PUT /matches/1.json
  def update
    respond_to do |format|
      if @match.update(match_params)
        format.html { redirect_to @match, notice: 'Match was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matches/1
  # DELETE /matches/1.json
  def destroy
    if @match.player1_id == current_user.id 
      @match.player1_id = nil
      
      if @match.player2_id
        @match.player1_id, @match.player2_id = @match.player2_id, @match.player1_id
      elsif @match.player3_id
        @match.player1_id, @match.player3_id = @match.player3_id, @match.player1_id 
      elsif @match.player4_id
        @match.player1_id, @match.player4_id = @match.player4_id, @match.player1_id 
      end
      
      if @match.player1_id.nil? then @match.destroy end

    elsif @match.player2_id == current_user.id then @match.player2_id = nil
    elsif @match.player3_id == current_user.id then @match.player3_id = nil
    elsif @match.player4_id == current_user.id then @match.player4_id = nil 
    end
    respond_to do |format|
      format.html { redirect_to matches_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def match_params
      params.require(:match).permit(:start, :end, :court, :desc, :match_type)
    end
end