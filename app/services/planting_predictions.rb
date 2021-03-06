class PlantingPredictions
  def initialize(planting)
    @planting = planting
  end

  def days_until_finished
    return 0 if @planting.finished?
    days = (@planting.finished_at - Date.current).to_i
    days.positive? ? days : 0
  end

  def days_until_mature
    days = ((@planting.planted_at + @planting.days_before_maturity) - Date.current).to_i
    days.positive? ? days : 0
  end

  def percentage_grown
    return nil unless @planting.days_before_maturity && @planting.planted?

    days = (Date.current - @planting.planted_at.to_date).to_f

    return 0 if Date.current < @planting.planted_at
    return 100 if days > @planting.days_before_maturity
    percent = (days / @planting.days_before_maturity * 100).to_i

    percent = 100 if percent >= 100

    percent
  end

  def start_to_finish_diff
    (@planting.finished_at - @planting.planted_at).to_i if @planting.finished_at && @planting.planted_at
  end

  def predict_days_before_maturity
    # calculate the number of days, from planted_at, until maturity
    if @planting.planted_at && @planting.finished_at
      start_to_finish_diff
    elsif @planting.crop_id
      plantings = other_finished_plantings_same_crop
      PlantingPredictions.mean_days_until_maturity(plantings)
    end
  end

  def self.mean_days_until_maturity(plantings)
    ## Given a set of finished plantings, calculate the average/mean time from start to finish
    differences = plantings.collect(&:start_to_finish_diff)
    differences.compact.sum / differences.compact.size unless differences.compact.empty?
  end

  private

  def other_finished_plantings_same_crop
    Planting.where(crop_id: @planting.crop_id)
      .where.not(id: @planting.id)
      .where.not(finished_at: nil)
  end
end
