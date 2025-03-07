import { Drawer, Descriptions, Typography, Image, List } from "antd";
const { Title, Text } = Typography;

const DetailBranch = (props) => {
  const { dataDetail, setDataDetail, isDataDetailOpen, setIsDataDetailOpen } = props;

  return (
    <Drawer
      title={<Title level={4}>Branch Detail</Title>}
      onClose={() => {
        setDataDetail(null);
        setIsDataDetailOpen(false);
      }}
      open={isDataDetailOpen}
      width={600}
      footer={
        <Text type="secondary">
          Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi. Để biết thêm chi tiết, vui lòng liên hệ với bộ phận hỗ trợ.
        </Text>
      }
    >
      {dataDetail ? (
        <>
          <Descriptions
            bordered
            column={1}
            size="small"
            labelStyle={{ fontWeight: "bold", width: "30%" }}
            contentStyle={{ background: "#fafafa" }}
          >
            <Descriptions.Item label="ID">{dataDetail.id}</Descriptions.Item>
            <Descriptions.Item label="Branch Name">{dataDetail.branchName}</Descriptions.Item>
            <Descriptions.Item label="Address">{dataDetail.address}</Descriptions.Item>
            <Descriptions.Item label="Phone Number">{dataDetail.phoneNumber}</Descriptions.Item>
            <Descriptions.Item label="Email">{dataDetail.email}</Descriptions.Item>
            <Descriptions.Item label="Open Hour">{`${dataDetail.openHours[0]}:${dataDetail.openHours[1]}`}</Descriptions.Item>
            <Descriptions.Item label="Close Hour">{`${dataDetail.closeHours[0]}:${dataDetail.closeHours[1]}`}</Descriptions.Item>
            <Descriptions.Item label="Services">
              {dataDetail.services && dataDetail.services.length > 0
                ? dataDetail.services.join(", ")
                : "No services available"}
            </Descriptions.Item>
          </Descriptions>
        </>
      ) : (
        <div style={{ textAlign: "center", color: "red" }}>
          <h3>Không có dữ liệu ở đây!</h3>
        </div>
      )}
    </Drawer>
  );
};

export default DetailBranch;
