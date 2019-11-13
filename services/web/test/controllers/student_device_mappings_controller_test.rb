require 'test_helper'

class StudentDeviceMappingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student_device_mapping = student_device_mappings(:one)
  end

  test "should get index" do
    get student_device_mappings_url
    assert_response :success
  end

  test "should get new" do
    get new_student_device_mapping_url
    assert_response :success
  end

  test "should create student_device_mapping" do
    assert_difference('StudentDeviceMapping.count') do
      post student_device_mappings_url, params: { student_device_mapping: { device_id: @student_device_mapping.device_id, device_type: @student_device_mapping.device_type, student_id: @student_device_mapping.student_id } }
    end

    assert_redirected_to student_device_mapping_url(StudentDeviceMapping.last)
  end

  test "should show student_device_mapping" do
    get student_device_mapping_url(@student_device_mapping)
    assert_response :success
  end

  test "should get edit" do
    get edit_student_device_mapping_url(@student_device_mapping)
    assert_response :success
  end

  test "should update student_device_mapping" do
    patch student_device_mapping_url(@student_device_mapping), params: { student_device_mapping: { device_id: @student_device_mapping.device_id, device_type: @student_device_mapping.device_type, student_id: @student_device_mapping.student_id } }
    assert_redirected_to student_device_mapping_url(@student_device_mapping)
  end

  test "should destroy student_device_mapping" do
    assert_difference('StudentDeviceMapping.count', -1) do
      delete student_device_mapping_url(@student_device_mapping)
    end

    assert_redirected_to student_device_mappings_url
  end
end